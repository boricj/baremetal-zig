const intrinsics = @import("intrinsics.zig");

// This function is the entry point of the aarch64 port of the kernel. It is
// marked with a naked calling convention to inhibit the generation of a
// prologue and epilogue because at this point the stack is not initialized.
// Futhermore, it is marked as never returning because there is nothing to
// return to.
pub fn start() callconv(.Naked) noreturn {
    // Without a working stack, there is little the kernel can do safely other
    // than hang because we can't call functions or use local variables.
    while (true) {
        intrinsics.waitForInterrupt();
    }

    unreachable;
}
