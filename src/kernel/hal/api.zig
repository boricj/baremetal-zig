// This is the public-facing API of the hardware abstraction layer module.

// The HAL isolates the architecture-specific bits of a port from the rest of
// the kernel. This helps the portability of the kernel by exposing a hardware-
// independent interface that the rest of the kernel can rely on for low-level,
// processor-specific operations.

const builtin = @import("builtin");
const std = @import("std");

const arch = builtin.cpu.arch;
const Arch = std.Target.Cpu.Arch;

const modAddress = @import("address.zig");

pub const PhysicalAddress = modAddress.PhysicalAddress;
pub const VirtualAddress = modAddress.VirtualAddress;

const modDebugWriter = switch (arch) {
    Arch.aarch64 => @import("aarch64/debugWriter.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const debugWriter = modDebugWriter.debugWriter;

const modFrame = switch (arch) {
    Arch.aarch64 => @import("aarch64/frame.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const Frame = modFrame.Frame;

const modIntrinsics = switch (arch) {
    Arch.aarch64 => @import("aarch64/intrinsics.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const breakpoint = modIntrinsics.breakpoint;
pub const waitForInterrupt = modIntrinsics.waitForInterrupt;

const modTimer = switch (arch) {
    Arch.aarch64 => @import("aarch64/timer.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const getMonotonicTimestamp = modTimer.getMonotonicTimestamp;

const modTrap = @import("trap.zig");

pub const Trap = modTrap.Trap;

const modTimestamp = @import("timestamp.zig");

pub const Timestamp = modTimestamp.Timestamp;

const modStart = switch (arch) {
    Arch.aarch64 => @import("aarch64/start.zig"),
    else => @panic("Unknown CPU architecture!"),
};

pub const start = modStart.start;
