const builtin = @import("builtin");
const std = @import("std");

const hal = @import("hal/api.zig");

// This aliases the arch-specific entrypoint of the kernel to a generic symbol.
comptime {
    @export(hal.start, .{ .name = "_start", .linkage = .Strong });
}
