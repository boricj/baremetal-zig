const std = @import("std");
const builtin = @import("builtin");

const hal = @import("../hal/api.zig");

const arch = builtin.cpu.arch;
const Arch = std.Target.Cpu.Arch;

// This function is called by the HAL module whenever the processor encountered
// an interrupt.
pub fn handleInterrupt(interrupt: hal.Interrupt) void {
    std.log.debug("{}", .{interrupt});

    if (interrupt.isTimer) {
        hal.scheduleTimer(hal.Timestamp{ .ticks = 1, .frequency = 1 });
        hal.acknowledgeInterrupt(interrupt.number);
    }

    interrupt.frame.switchTo();
}
