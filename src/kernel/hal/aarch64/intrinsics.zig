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

pub inline fn waitForInterrupt() void {
    asm volatile (
        \\ wfi
    );
}
