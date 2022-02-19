const hal = @import("../api.zig");

const interrupt = @import("interrupt.zig");
const intrinsics = @import("intrinsics.zig");

// The monotonic clock on aarch64 is provided by the Generic Timer (cf. "AArch64
// Programmer's Guides Generic Timer").
pub inline fn getMonotonicTimestamp() hal.Timestamp {
    return hal.Timestamp{
        .ticks = intrinsics.readCNTPCT_EL0(),
        .frequency = intrinsics.readCNTFRQ_EL0(),
    };
}

pub fn scheduleTimer(timeout: ?hal.Timestamp) void {
    if (timeout) |deadline| {
        const ticks = intrinsics.readCNTPCT_EL0() + (deadline.ticks * intrinsics.readCNTFRQ_EL0() / deadline.frequency);

        intrinsics.writeCNTP_CVAL_EL0(ticks);
        intrinsics.writeCNTP_CTL_EL0(1);
        hal.enableInterrupt(interrupt.TIMER_INTERRUPT);
    } else {
        intrinsics.writeCNTP_CTL_EL0(0);
        hal.disableInterrupt(interrupt.TIMER_INTERRUPT);
    }
}
