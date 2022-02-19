// This is the public-facing API of the hardware abstraction layer module.

// The HAL isolates the architecture-specific bits of a port from the rest of
// the kernel. This helps the portability of the kernel by exposing a hardware-
// independent interface that the rest of the kernel can rely on for low-level,
// processor-specific operations.

const builtin = @import("builtin");
const std = @import("std");

const Arch = std.Target.Cpu.Arch;
const arch = builtin.cpu.arch;

const modIntrinsics = switch (arch) {
    Arch.aarch64 => @import("aarch64/intrinsics.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const waitForInterrupt = modIntrinsics.waitForInterrupt;

const modStart = switch (arch) {
    Arch.aarch64 => @import("aarch64/start.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const start = modStart.start;
