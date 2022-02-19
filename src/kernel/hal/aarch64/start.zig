const std = @import("std");

const interrupt = @import("interrupt.zig");
const intrinsics = @import("intrinsics.zig");
const vector = @import("vector.zig");

extern fn main() void;

// This function is the entry point of the aarch64 port of the kernel. It is
// marked with a naked calling convention to inhibit the generation of a
// prologue and epilogue because at this point the stack is not initialized.
// Futhermore, it is marked as never returning because there is nothing to
// return to.
pub fn start() callconv(.Naked) noreturn {
    asm volatile (
    // Initialize the stack. The aarch64 calling convention mandates that
    // the stack pointer be 16-byte aligned (cf. "Universal stack
    // constraints" section of "Procedure Call Standard for the Arm® 64-bit
    // Architecture").
        \\ ldr x30, =stack_top
        \\ and sp, x30, #0xfffffffffffffff0
    );
    vector.initializeVectorEL1();
    interrupt.initialize();

    std.log.debug("Calling main()", .{});
    main();
    std.log.warn("main() returned, hanging...", .{});

    while (true) {
        intrinsics.waitForInterrupt();
    }

    unreachable;
}
