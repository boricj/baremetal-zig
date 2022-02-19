ENTRY(_start)
SECTIONS {
    . = 0x40000000;

    .text : ALIGN(4K) {
        *(.text)
    }

    .rodata : ALIGN(4K) {
        *(.rodata)
    }

    .data : ALIGN(4K) {
        *(.data)
    }

    .bss : ALIGN(4K) {
        *(.bss COMMON)
    }

    . = ALIGN(4K);
    . += 0x10000; /* 64kB of stack memory */
    stack_top = .;
}
