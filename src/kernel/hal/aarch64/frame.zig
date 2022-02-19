const std = @import("std");

const cpu = @import("cpu.zig");

const assert = std.debug.assert;

// This structure represents a context execution that has been interrupted by a
// trap or an interrupt. It consists of all the general-purpose registers that
// need to be preserved prior to handling the trap or interrupt within the
// kernel. While it is the most basic building block of a thread, it does not
// include the complete processor state, such as floating-point or vector
// registers.
pub const Frame = packed struct {
    x0: u64,
    x1: u64,
    x2: u64,
    x3: u64,
    x4: u64,
    x5: u64,
    x6: u64,
    x7: u64,
    x8: u64,
    x9: u64,
    x10: u64,
    x11: u64,
    x12: u64,
    x13: u64,
    x14: u64,
    x15: u64,
    x16: u64,
    x17: u64,
    x18: u64,
    x19: u64,
    x20: u64,
    x21: u64,
    x22: u64,
    x23: u64,
    x24: u64,
    x25: u64,
    x26: u64,
    x27: u64,
    x28: u64,
    fp: u64,
    lr: u64,
    sp: u64,
    pc: u64,
    cpsr: cpu.ProgramStatusRegister,

    pub fn format(
        self: Frame,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        inline for (@typeInfo(@This()).Struct.fields) |f, i| {
            if (i > 0) {
                if (i % 4 == 0) {
                    try writer.writeAll("\n");
                } else {
                    try writer.writeAll(" ");
                }
            }
            try writer.print("{s: >4}=0x{x:0>16}", .{ f.name, @field(self, f.name) });
        }
    }

    // The switchTo() method resumes the execution of a frame. It is marked as
    // no return because upon executing the eret instruction the processor will
    // jump back into this execution context, possibly changing exception
    // levels too, at which point the current exception context will have been
    // overwritten and cannot be returned to.
    pub fn switchTo(self: Frame) noreturn {
        asm volatile (
            \\ ldp x2, x3, [x0, #248]
            \\ ldr x4, [x0, #264]
            \\ mov sp, x2
            \\ msr SP_EL0, x2
            \\ msr ELR_EL1, x3
            \\ msr SPSR_EL1, x4
            \\ ldp x2, x3, [x0, #16]
            \\ ldp x4, x5, [x0, #32]
            \\ ldp x6, x7, [x0, #48]
            \\ ldp x8, x9, [x0, #64]
            \\ ldp x10, x11, [x0, #80]
            \\ ldp x12, x13, [x0, #96]
            \\ ldp x14, x15, [x0, #112]
            \\ ldp x16, x17, [x0, #128]
            \\ ldp x18, x19, [x0, #144]
            \\ ldp x20, x21, [x0, #160]
            \\ ldp x22, x23, [x0, #176]
            \\ ldp x24, x25, [x0, #192]
            \\ ldp x26, x27, [x0, #208]
            \\ ldp x28, x29, [x0, #224]
            \\ ldr x30, [x0, #224]
            \\ ldp x0, x1, [x0, #0]
            \\ eret
            :
            : [self] "{x0}" (self),
        );
        unreachable;
    }
};

comptime {
    assert(@sizeOf(Frame) == 272);
}
