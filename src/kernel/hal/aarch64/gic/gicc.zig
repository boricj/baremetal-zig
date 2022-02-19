const std = @import("std");

const hal = @import("../../api.zig");

const assert = std.debug.assert;
const VirtualAddress = hal.VirtualAddress;

// cf. "ARM Generic Interrupt Controller Architecture version 2.0 - Architecture
// Specification"

// 4.4.1 CPU Interface Control Register, GICC_CTLR
const CTRL = packed struct {
    enable: bool,
    res0: u31,
};

comptime {
    assert(@bitSizeOf(CTRL) == 32);
}

// 4.4.2 Interrupt Priority Mask Register, GICC_PMR
const PMR = packed struct {
    priority: u8,
    res0: u24,
};

comptime {
    assert(@bitSizeOf(PMR) == 32);
}

// 4.4.7 Highest Priority Pending Interrupt Register, GICC_HPPIR
const HPPIR = packed struct {
    pendIntId: u10,
    cpuId: u3,
    res0: u19,
};

comptime {
    assert(@bitSizeOf(HPPIR) == 32);
}

// 4.4.14 CPU Interface Identification Register, GICC_IIDR
const IIDR = packed struct {
    implementer: u12,
    revision: u4,
    archRevision: u4,
    res1: u12,
};

comptime {
    assert(@bitSizeOf(IIDR) == 32);
}

// 4.1.3 CPU interface register map
const OFFSET_CTRL = 0x0000;
const OFFSET_PMR = 0x0004;
const OFFSET_HPPIR = 0x0018;
const OFFSET_IIDR = 0x00FC;

pub const GICC = struct {
    base_address: VirtualAddress,

    inline fn ctrl(self: GICC) *volatile CTRL {
        return @intToPtr(*volatile CTRL, self.base_address.addr + OFFSET_CTRL);
    }

    inline fn pmr(self: GICC) *volatile PMR {
        return @intToPtr(*volatile PMR, self.base_address.addr + OFFSET_PMR);
    }

    inline fn iidr(self: GICC) *volatile IIDR {
        return @intToPtr(*volatile IIDR, self.base_address.addr + OFFSET_IIDR);
    }

    inline fn hppir(self: GICC) *volatile HPPIR {
        return @intToPtr(*volatile HPPIR, self.base_address.addr + OFFSET_HPPIR);
    }

    pub fn initialize(self: GICC) void {
        const REG_IIDR = self.iidr();
        std.log.debug("General interrupt controller CPU interface version {}", .{REG_IIDR.archRevision});

        const REG_CTRL = self.ctrl();
        REG_CTRL.enable = true;

        const REG_PMR = self.pmr();
        REG_PMR.priority = 0xFF;
    }

    pub fn nextPendingInterrupt(self: GICC) ?u32 {
        const REG_HPPIR = self.hppir();

        const pendingInterrupt = REG_HPPIR.pendIntId;
        if (pendingInterrupt == 0x3FF) {
            return null;
        } else {
            return pendingInterrupt;
        }
    }
};
