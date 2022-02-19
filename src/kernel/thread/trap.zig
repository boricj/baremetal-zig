const std = @import("std");

const hal = @import("../hal/api.zig");

// This function is called by the HAL module whenever the processor encountered
// a trap.
pub fn handleTrap(trap: hal.Trap) void {
    std.log.debug("{}", .{trap});
}
