const hal = @import("../api.zig");

const intrinsics = @import("intrinsics.zig");

// The monotonic clock on aarch64 is provided by the Generic Timer (cf. "AArch64
// Programmer's Guides Generic Timer").
pub inline fn getMonotonicTimestamp() hal.Timestamp {
    return hal.Timestamp{
        .ticks = intrinsics.readCNTPCT_EL0(),
        .frequency = intrinsics.readCNTFRQ_EL0(),
    };
}
