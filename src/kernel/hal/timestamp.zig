const std = @import("std");

pub const Timestamp = struct {
    ticks: u64,
    frequency: u64,

    pub fn getSeconds(self: Timestamp) u64 {
        return self.ticks / self.frequency;
    }

    pub fn getMilliseconds(self: Timestamp) u64 {
        return ((self.ticks % self.frequency) * 1000) / self.frequency;
    }

    pub fn getMicroseconds(self: Timestamp) u64 {
        return ((self.ticks % self.frequency) * 1000000) / self.frequency;
    }

    pub fn getNanoseconds(self: Timestamp) u64 {
        return ((self.ticks % self.frequency) * 1000000000) / self.frequency;
    }
};
