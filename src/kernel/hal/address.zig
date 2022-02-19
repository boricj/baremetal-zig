const builtin = @import("builtin");
const std = @import("std");

const arch = builtin.cpu.arch;
const Arch = std.Target.Cpu.Arch;

const modCpu = switch (arch) {
    Arch.aarch64 => @import("aarch64/cpu.zig"),
    else => @panic("Unknown CPU architecture!"),
};

fn Address(
    comptime RawType: type,
    comptime prefix: anytype,
) type {
    return packed struct {
        addr: RawType,

        pub fn format(
            self: @This(),
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;

            try writer.print(prefix ++ "@0x{x:0>" ++ std.fmt.comptimePrint("{d}", .{@typeInfo(RawType).Int.bits / 4}) ++ "}", .{self.addr});
        }
    };
}

// Structure representing an address on the physical space.
pub const PhysicalAddress = Address(modCpu.PhysicalAddressRawType, "P");

// Structure representing an address on the virtual space.
pub const VirtualAddress = Address(modCpu.VirtualAddressRawType, "V");
