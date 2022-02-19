// This is the public-facing API of the thread module.

// The thread modules handles everything related to threads. This includes
// notably processor exceptions.

const trap = @import("trap.zig");

pub const handleTrap = trap.handleTrap;
