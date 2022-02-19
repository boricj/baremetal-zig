const builtin = @import("builtin");
const std = @import("std");

const hal = @import("hal/api.zig");

// This aliases the arch-specific entrypoint of the kernel to a generic symbol.
comptime {
    @export(hal.start, .{ .name = "_start", .linkage = .Strong });
}

// Override the global Zig log level so that informational messages and higher
// are always enabled.
pub const log_level: std.log.Level = switch (builtin.mode) {
    .Debug => .debug,
    else => .info,
};

// Custom logging function for the kernel, as the kernel isn't a normal userland
// program and requires specific log handling.
pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const prefix = if (scope == .default) "kernel: " else @tagName(scope) ++ ": ";

    // The debug log is colored with ANSI escape sequences, which are
    // interpreted by the terminal (cf. "ECMA-48, 5th edition, June 1991").
    const color = switch (message_level) {
        std.log.Level.err => "\x1b[31m", // Red
        std.log.Level.warn => "\x1b[33m", // Yellow
        std.log.Level.info => "\x1b[37m", // White
        std.log.Level.debug => "\x1b[36m", // Cyan
    };

    const timestamp = hal.getMonotonicTimestamp();

    // The timestamp is formatted without using floating point variables.
    hal.debugWriter.print(color ++ "[{d: >9}.{d:0>9}] ", .{ timestamp.getSeconds(), timestamp.getNanoseconds() }) catch unreachable;
    hal.debugWriter.print(prefix ++ format, args) catch unreachable;
    hal.debugWriter.print("\x1b[00m\n", .{}) catch unreachable; // Reset colors.
}

// Architecture-independent entrypoint for the kernel, called by the HAL.
export fn main() void {
    std.log.info("All your codebase are belong to us.", .{});
}
