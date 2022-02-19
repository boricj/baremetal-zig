const std = @import("std");

const hal = @import("api.zig");

pub const Interrupt = struct {
    frame: *hal.Frame,
    number: u32,
    isTimer: bool,

    pub fn format(
        self: Interrupt,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("Interrupt {d} isTimer={b}\n{}", .{
            self.number,
            self.isTimer,
            self.frame,
        });
    }
};
