const std = @import("std");

const hal = @import("../../api.zig");

const assert = std.debug.assert;
const VirtualAddress = hal.VirtualAddress;

// cf. "ARM Generic Interrupt Controller Architecture version 2.0 - Architecture
// Specification"

// 4.3.1 Distributor Control Register, GICD_CTLR
const GICD_CTLR = packed struct {
    enable: bool,
    res0: u31,
};

comptime {
    assert(@bitSizeOf(GICD_CTLR) == 32);
}

// 4.3.2 Interrupt Controller Type Register, GICD_TYPER
const GICD_TYPER = packed struct {
    itLinesNumber: u5,
    cpuNumber: u3,
    res0: u2,
    securityExtn: bool,
    lspi: u5,
    res1: u16,
};

comptime {
    assert(@bitSizeOf(GICD_TYPER) == 32);
}

// 4.3.3 Distributor Implementer Identification Register, GICD_IIDR
const GICD_IIDR = packed struct {
    implementer: u12,
    revision: u4,
    variant: u4,
    res0: u4,
    productId: u8,
};

comptime {
    assert(@bitSizeOf(GICD_IIDR) == 32);
}

// 4.3.13 Interrupt Configuration Registers, GICD_ICFGRn
const GICD_ICFGRn = packed struct {
    res0: bool,
    isEdgeTriggered: bool,
};

// 4.3.15 Software Generated Interrupt Register, GICD_SGIR
const GICD_SGIR_TargetListFilter = enum(u2) {
    FORWARD_TO_CPU_IN_TARGET_LIST,
    FORWARD_TO_ALL_EXCEPT_SELF,
    FORWARD_TO_SELF,
    RESERVED0,
};

const GICD_SGIR = packed struct {
    sgIntId: u4,
    res0: u11,
    nsAtt: bool,
    cpuTargetList: u8,
    targetListFilter: GICD_SGIR_TargetListFilter,
    res1: u6,
};

comptime {
    assert(@bitSizeOf(GICD_SGIR) == 32);
}

// 4.3.18 Identification registers
const ICPIDR2 = packed struct {
    res0: u4,
    archRevision: u4,
    res1: u24,
};

comptime {
    assert(@bitSizeOf(ICPIDR2) == 32);
}

// 4.1.2 Distributor register map
const OFFSET_CTLR = 0x000;
const OFFSET_ISENABLER = 0x100;
const OFFSET_ICENABLER = 0x180;
const OFFSET_ISPENDR = 0x200;
const OFFSET_ICPENDR = 0x280;
const OFFSET_ISACTIVER = 0x300;
const OFFSET_ICACTIVER = 0x380;
const OFFSET_ICPIDR2 = 0xFE8;

pub const GICD = struct {
    base_address: VirtualAddress,

    inline fn writeBit(self: GICD, base_offset: u32, bit: u32) void {
        const reg = @intToPtr(*volatile u32, self.base_address.addr + base_offset + (bit / 32) * @sizeOf(u32));
        reg.* |= @as(u32, 1) << @intCast(u5, bit % 32);
    }

    inline fn icpidr2(self: GICD) *volatile ICPIDR2 {
        return @intToPtr(*volatile ICPIDR2, self.base_address.addr + OFFSET_ICPIDR2);
    }

    pub fn initialize(self: GICD) void {
        const REG_ICPIDR2 = self.icpidr2();
        std.log.debug("General interrupt controller distributor version {}", .{REG_ICPIDR2.archRevision});

        const REG_GICD_CTLR = @intToPtr(*volatile GICD_CTLR, self.base_address.addr + OFFSET_CTLR);
        REG_GICD_CTLR.enable = true;
    }

    pub fn acknowledgeInterrupt(self: GICD, number: u32) void {
        self.writeBit(OFFSET_ICPENDR, number);
    }

    pub fn enableInterrupt(self: GICD, number: u32) void {
        self.writeBit(OFFSET_ISENABLER, number);
    }

    pub fn disableInterrupt(self: GICD, number: u32) void {
        self.writeBit(OFFSET_ICENABLER, number);
    }
};
