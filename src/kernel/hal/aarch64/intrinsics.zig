const hal = @import("../api.zig");

const cpu = @import("cpu.zig");

pub inline fn breakpoint() void {
    asm volatile (
        \\ brk #0
    );
}

pub inline fn readCNTFRQ_EL0() u64 {
    return asm volatile (
        \\ mrs x0, CNTFRQ_EL0
        : [ret] "={x0}" (-> u64),
    );
}

pub inline fn readCNTPCT_EL0() u64 {
    // There is an instruction barrier before reading the counter because the
    // processor might speculatively execute instructions beyond this point
    // before the counter value is read (cf. "3.1 Count and frequency" section
    // of "AArch64 Programmer's Guides Generic Timer").
    return asm volatile (
        \\ isb
        \\ mrs x0, CNTPCT_EL0
        : [ret] "={x0}" (-> u64),
    );
}

pub inline fn readESR_EL1() cpu.ExceptionSyndrome {
    const val: u64 = asm volatile (
        \\ mrs x0, ESR_EL1
        : [ret] "={x0}" (-> u64),
    );

    return @bitCast(cpu.ExceptionSyndrome, val);
}

pub inline fn readFAR_EL1() hal.VirtualAddress {
    const val: u64 = asm volatile (
        \\ mrs x0, FAR_EL1
        : [ret] "={x0}" (-> u64),
    );

    return @bitCast(hal.VirtualAddress, val);
}

pub inline fn waitForInterrupt() void {
    asm volatile (
        \\ wfi
    );
}

pub inline fn writeVBAR_EL1(value: u64) void {
    asm volatile (
        \\ msr vbar_el1, x0
        :
        : [value] "{x0}" (value),
    );
}
