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
};

comptime {
    assert(@sizeOf(Frame) == 272);
}
