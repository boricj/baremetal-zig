pub inline fn waitForInterrupt() void {
    asm volatile (
        \\ wfi
    );
}
