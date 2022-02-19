const std = @import("std");

const hal = @import("api.zig");

pub const Trap = struct {
    pub const PrivilegeLevel = enum {
        USER,
        KERNEL,
    };

    pub const Operation = enum {
        EXECUTE,
        WRITE,
        READ,
    };

    pub const Reason = enum {
        ACCESS_VIOLATION,
        ACCESS_UNALIGNED,
        INSTRUCTION_ILLEGAL,
        INSTRUCTION_STEP,
        SOFTWARE_BREAKPOINT,
        HARDWARE_BREAKPOINT,
    };

    frame: *hal.Frame,
    privilegeLevel: PrivilegeLevel,
    operation: Operation,
    reason: Reason,
    address: hal.VirtualAddress,

    pub fn format(
        self: Trap,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("Trap {s} {s} {s} {}\n{}", .{
            @tagName(self.privilegeLevel),
            @tagName(self.operation),
            @tagName(self.reason),
            self.address,
            self.frame,
        });
    }
};
