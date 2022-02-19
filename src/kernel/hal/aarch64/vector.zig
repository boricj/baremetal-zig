const std = @import("std");

const modCpu = @import("cpu.zig");
const modIntrinsics = @import("intrinsics.zig");
const modFrame = @import("frame.zig");

const modHal = @import("../api.zig");
const modThread = @import("../../thread/api.zig");

const ExceptionClass = modCpu.ExceptionSyndrome.ExceptionClass;
const ExceptionType = modCpu.ExceptionType;
const Frame = modFrame.Frame;
const readESR_EL1 = modIntrinsics.readESR_EL1;
const readFAR_EL1 = modIntrinsics.readFAR_EL1;
const Trap = modHal.Trap;
const VirtualAddress = modHal.VirtualAddress;
const waitForInterrupt = modIntrinsics.waitForInterrupt;
const writeVBAR_EL1 = modIntrinsics.writeVBAR_EL1;

// This is the EL1 vector table. The processor will jump to one of the vector
// whenever it encounters an exception or an interrupt. Our handler saves all
// general-purpose registers of the previous execution context (called the trap
// frame) on the kernel stack in order to preserve it and then calls the arch-
// specific handleExceptionEL1 function to actually handle the exception. Saving
// the previous execution context first is needed to eventually resume it,
// before it gets overwritten by the exception handling.
comptime {
    asm (
    // This macro pushes the trap frame on the stack. It handles variations
    // depending on which exception level the exception was generated on.
        \\ .macro pushTrapFrame el ELR SPSR
        \\      sub sp, sp, #272
        \\      stp x0, x1, [sp, #0]
        \\      stp x2, x3, [sp, #16]
        \\      stp x4, x5, [sp, #32]
        \\      stp x6, x7, [sp, #48]
        \\      stp x8, x9, [sp, #64]
        \\      stp x10, x11, [sp, #80]
        \\      stp x12, x13, [sp, #96]
        \\      stp x14, x15, [sp, #112]
        \\      stp x16, x17, [sp, #128]
        \\      stp x18, x19, [sp, #144]
        \\      stp x20, x21, [sp, #160]
        \\      stp x22, x23, [sp, #176]
        \\      stp x24, x25, [sp, #192]
        \\      stp x26, x27, [sp, #208]
        \\      stp x28, x29, [sp, #224]
        \\ .if \el == 0
        \\      mrs	x0, sp_el0
        \\  .else
        \\      add x0, sp, #272
        \\  .endif
        \\      mrs x1, \ELR
        \\      mrs x2, \SPSR
        \\      stp x30, x0, [sp, #240]
        \\      stp x1, x2, [sp, #256]
        \\ .endm

        // This macro calls the handleExceptionEL1 function.
        \\ .macro callHandleExceptionEL1 idx
        \\      mov x0, sp
        \\      mov x1, #\idx
        \\      bl handleExceptionEL1
        \\ .endm

        // The EL1 vector table itself. The processor jumps to one of the vectors
        // upon encountering an exception. Since each vector has room for up to 32
        // instructions, the vectors save the trap frame before immediately handing
        // it off to the handleExceptionEL1 function.
        \\ .text
        \\ .global el1_vector_table
        \\ .balign 2048
        \\ el1_vector_table:
        \\
        \\ .balign 0x80
        \\ el1_synchronous_el1t:
        \\      b .
        \\ .balign 0x80
        \\ el1_irq_el1t:
        \\      b .
        \\ .balign 0x80
        \\ el1_fiq_el1t:
        \\      b .
        \\ .balign 0x80
        \\ el1_serror_elt1t:
        \\      b .
        \\
        \\ .balign 0x80
        \\ el1_synchronous_el1h:
        \\      pushTrapFrame 1 ELR_EL1 SPSR_EL1
        \\      callHandleExceptionEL1 4
        \\ .balign 0x80
        \\ el1_irq_el1h:
        \\      pushTrapFrame 1 ELR_EL1 SPSR_EL1
        \\      callHandleExceptionEL1 5
        \\ .balign 0x80
        \\ el1_fiq_el1h:
        \\      pushTrapFrame 1 ELR_EL1 SPSR_EL1
        \\      callHandleExceptionEL1 6
        \\ .balign 0x80
        \\ el1_serror_elt1h:
        \\      pushTrapFrame 1 ELR_EL1 SPSR_EL1
        \\      callHandleExceptionEL1 7
        \\
        \\ .balign 0x80
        \\ el1_synchronous_aarch64:
        \\      b .
        \\ .balign 0x80
        \\ el1_irq_aarch64:
        \\      b .
        \\ .balign 0x80
        \\ el1_fiq_aarch64:
        \\      b .
        \\ .balign 0x80
        \\ el1_serror_aarch64:
        \\      b .
        \\
        \\ .balign 0x80
        \\ el1_synchronous_aarch32:
        \\      b .
        \\ .balign 0x80
        \\ el1_irq_aarch32:
        \\      b .
        \\ .balign 0x80
        \\ el1_fiq_aarch32:
        \\      b .
        \\ .balign 0x80
        \\ el1_serror_aarch32:
        \\      b .
        \\ .balign 0x80
    );
}

extern const el1_vector_table: [16]u128;

fn buildTrap(frame: *Frame, exceptionType: ExceptionType) Trap {
    const exceptionSyndrome = readESR_EL1();

    const operation = switch (exceptionSyndrome.ec) {
        ExceptionClass.DATA_ABORT_LOWER_EL, ExceptionClass.DATA_ABORT_SAME_EL => Trap.Operation.READ,
        ExceptionClass.WATCHPOINT_LOWER_EL, ExceptionClass.WATCHPOINT_SAME_EL => Trap.Operation.READ,
        ExceptionClass.SP_ALIGNMENT => Trap.Operation.READ,
        else => Trap.Operation.EXECUTE,
    };

    const reason = switch (exceptionSyndrome.ec) {
        ExceptionClass.PC_ALIGNMENT, ExceptionClass.SP_ALIGNMENT => Trap.Reason.ACCESS_UNALIGNED,
        ExceptionClass.BRKPT_AARCH32, ExceptionClass.BRK_AARCH64 => Trap.Reason.SOFTWARE_BREAKPOINT,
        ExceptionClass.SOFTWARE_STEP_LOWER_EL, ExceptionClass.SOFTWARE_STEP_SAME_EL => Trap.Reason.INSTRUCTION_STEP,
        else => Trap.Reason.INSTRUCTION_ILLEGAL,
    };

    const privilegeLevel = switch (exceptionType) {
        ExceptionType.SYNCHRONOUS_EL1T, ExceptionType.SYNCHRONOUS_EL1H => Trap.PrivilegeLevel.KERNEL,
        ExceptionType.SYNCHRONOUS_AARCH64_EL0, ExceptionType.SYNCHRONOUS_AARCH32_EL0 => Trap.PrivilegeLevel.USER,
        else => @panic("Bad exception type!"),
    };

    const address = switch (operation) {
        Trap.Operation.EXECUTE => @bitCast(VirtualAddress, frame.pc),
        else => readFAR_EL1(),
    };

    return Trap{
        .frame = frame,
        .operation = operation,
        .reason = reason,
        .privilegeLevel = privilegeLevel,
        .address = address,
    };
}

pub fn initializeVectorEL1() void {
    writeVBAR_EL1(@ptrToInt(&el1_vector_table));
}

// This function is called from the EL1 vector table to handle. It is marked as
// no return because the kernel is expected to eventually resume a trap frame by
// calling its hal.Trap.frame.switchTo() function.
export fn handleExceptionEL1(frame: *Frame, exceptionType: ExceptionType) noreturn {
    _ = switch (exceptionType) {
        ExceptionType.SYNCHRONOUS_EL1H => modThread.handleTrap(buildTrap(frame, exceptionType)),
        ExceptionType.SYNCHRONOUS_AARCH64_EL0 => modThread.handleTrap(buildTrap(frame, exceptionType)),
        else => false,
    };

    std.log.warn("Unhandled exception {s}, hanging...", .{@tagName(exceptionType)});

    while (true) {
        waitForInterrupt();
    }
}
