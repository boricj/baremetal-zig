const std = @import("std");

fn debugWrite(context: void, msg: []const u8) error{}!usize {
    _ = context;

    // As the aarch64 port currently targets only the QEMU virt platform, the
    // location and type of the UART are hard-coded for now (cf. "PrimeCell UART
    // (PL011) Technical Reference Manual"). This is a bare-bones implementation
    // just to get started, production systems should at least properly handle
    // FIFO buffering to prevent losing data due to transmission buffer
    // overflows.
    const uart_tx = @intToPtr([*]volatile u8, 0x09000000);

    for (msg) |c|
        uart_tx.* = c;

    return msg.len;
}

const DebugWriter = std.io.Writer(void, error{}, debugWrite);
pub const debugWriter = DebugWriter{
    .context = {},
};
