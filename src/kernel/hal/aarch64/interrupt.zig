const std = @import("std");

const GICC = @import("gic/gicc.zig");
const GICD = @import("gic/gicd.zig");

const gicc = GICC.GICC{ .base_address = .{ .addr = 0x08010000 } };
const gicd = GICD.GICD{ .base_address = .{ .addr = 0x08000000 } };

pub const TIMER_INTERRUPT = 30;

pub fn initialize() void {
    gicd.initialize();
    gicc.initialize();
}

pub fn acknowledge(number: u32) void {
    std.log.debug("Acknowledging interrupt {}", .{number});

    gicd.acknowledgeInterrupt(number);
}

pub fn disable(number: u32) void {
    std.log.debug("Disabling interrupt {}", .{number});

    gicd.disableInterrupt(number);
}

pub fn enable(number: u32) void {
    std.log.debug("Enabling interrupt {}", .{number});

    gicd.enableInterrupt(number);
}

pub fn nextPendingInterrupt() ?u32 {
    return gicc.nextPendingInterrupt();
}
