const std = @import("std");
const builtin = @import("builtin");

const hal = @import("../hal/api.zig");

const arch = builtin.cpu.arch;
const Arch = std.Target.Cpu.Arch;

// This function is called by the HAL module whenever the processor encountered
// a trap.
pub fn handleTrap(trap: hal.Trap) void {
    std.log.debug("{}", .{trap});

    if (trap.reason == hal.Trap.Reason.SOFTWARE_BREAKPOINT) {
        _ = switch (arch) {
            Arch.aarch64 => trap.frame.pc += 4,
            else => @panic("Unknown CPU architecture!"),
        };

        trap.frame.switchTo();
    }
}
