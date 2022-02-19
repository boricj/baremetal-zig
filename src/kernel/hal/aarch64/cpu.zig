const std = @import("std");

const assert = std.debug.assert;

pub const PhysicalAddressRawType = u64;
pub const VirtualAddressRawType = u64;

pub const ExceptionType = enum(u32) { SYNCHRONOUS_EL1T, IRQ_EL1T, FIQ_EL1T, SERROR_EL1T, SYNCHRONOUS_EL1H, IRQ_EL1H, FIQ_EL1H, SERROR_EL1H, SYNCHRONOUS_AARCH64_EL0, IRQ_AARCH64_EL0, FIQ_AARCH64_EL0, SERROR_AARCH64_EL0, SYNCHRONOUS_AARCH32_EL0, IRQ_AARCH32_EL0, FIQ_AARCH32_EL0, SERROR_AARCH32_EL0 };

// cf. "Arm® Architecture Reference Manual for A-profile architecture"

// C5.2.18 SPSR_EL1, Saved Program Status Register (EL1)
pub const ProgramStatusRegister = packed struct {
    pub const ExecutionState = enum(u5) {
        AARCH64_EL0t = 0b00000,
        AARCH64_EL1t = 0b00100,
        AARCH64_EL1h = 0b00101,
        AARCH32_USER = 0b10000,
        AARCH32_FIQ = 0b10001,
        AARCH32_IRQ = 0b10010,
        AARCH32_SUPERVISOR = 0b10011,
        AARCH32_ABORT = 0b10111,
        AARCH32_UNDEFINED = 0b11011,
        AARCH32_SYSTEM = 0b11111,
        _,
    };

    m: ExecutionState,
    res0: bool,
    f: bool,
    i: bool,
    a: bool,
    d: bool,
    btype: u2,
    ssbs: bool,
    allint: bool,
    res1: u6,
    il: bool,
    ss: bool,
    pan: bool,
    uao: bool,
    dit: bool,
    tco: bool,
    res2: u2,
    v: bool,
    c: bool,
    z: bool,
    n: bool,
    res3: u32,

    fn charOrDash(comptime char: u8, value: bool) u8 {
        if (value) {
            return char;
        } else {
            return '-';
        }
    }

    pub fn format(
        self: ProgramStatusRegister,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("{x:0>16}", .{@bitCast(u64, self)});
        try writer.print("  {c}{c}{c}{c} {c}{c} {c}{c}{c}{c} {s}", .{
            charOrDash('N', self.n),
            charOrDash('Z', self.z),
            charOrDash('C', self.c),
            charOrDash('V', self.v),
            charOrDash('I', self.il),
            charOrDash('S', self.ss),
            charOrDash('D', self.d),
            charOrDash('A', self.a),
            charOrDash('I', self.i),
            charOrDash('F', self.f),
            @tagName(self.m),
        });
    }
};

// D13.2.37 ESR_EL1, Exception Syndrome Register (EL1)
pub const ExceptionSyndrome = packed struct {
    pub const ExceptionClass = enum(u6) {
        UNKNOWN = 0b000000,
        TRAPPED_WFE_WFI = 0b000001,
        TRAPPED_MCR_MRC_COPROC15 = 0b000011,
        TRAPPED_MCRR_MRRC_COPROC15 = 0b000100,
        TRAPPED_MCR_MRC_COPROC14 = 0b000101,
        TRAPPED_LDC_STC = 0b000110,
        TRAPPED_FP = 0b000111,
        TRAPPED_VMRS = 0b001000,
        TRAPPED_POINTER_AUTHENTICATION = 0b001001,
        TRAPPED_LD64_ST64 = 0b001010,
        TRAPPED_MRRC_COPROC14 = 0b001100,
        BRANCH_TARGET = 0b001101,
        ILLEGAL_EXECUTION_STATE = 0b001110,
        SVC_AARCH32 = 0b010001,
        HVC_AARCH32 = 0b010010,
        SMC_AARCH32 = 0b010011,
        SVC_AARCH64 = 0b010101,
        HVC_AARCH64 = 0b010110,
        SMC_AARCH64 = 0b010111,
        TRAPPED_MSR_MRS_SYSTEM_AARCH64 = 0b011000,
        TRAPPED_SVE = 0b011001,
        TRAPPED_ERET = 0b011010,
        TRAPPED_POINTER_AUTHENTICATION_FAILURE = 0b011100,
        INSTRUCTION_ABORT_LOWER_EL = 0b100000,
        INSTRUCTION_ABORT_SAME_EL = 0b100001,
        PC_ALIGNMENT = 0b100010,
        DATA_ABORT_LOWER_EL = 0b100100,
        DATA_ABORT_SAME_EL = 0b100101,
        SP_ALIGNMENT = 0b100110,
        MEMORY_OPERATION = 0b100111,
        TRAPPED_FP_AARCH32 = 0b101000,
        TRAPPED_FP_AARCH64 = 0b101001,
        SERROR = 0b101111,
        BREAKPOINT_LOWER_EL = 0b110000,
        BREAKPOINT_SAME_EL = 0b110001,
        SOFTWARE_STEP_LOWER_EL = 0b110010,
        SOFTWARE_STEP_SAME_EL = 0b110011,
        WATCHPOINT_LOWER_EL = 0b110100,
        WATCHPOINT_SAME_EL = 0b110101,
        BRKPT_AARCH32 = 0b111000,
        VECTOR_AARCH32 = 0b111010,
        BRK_AARCH64 = 0b111100,
        _,
    };

    iss: u25,
    il: bool,
    ec: ExceptionClass,
    iss2: u5,
    res0: u27,

    pub fn format(
        self: ExceptionSyndrome,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("ESR={x:0>16} {s}", .{ @bitCast(u64, self), @tagName(self.ec) });
    }
};

comptime {
    assert(@bitSizeOf(ProgramStatusRegister) == 64);
    assert(@bitSizeOf(ExceptionSyndrome) == 64);
}
