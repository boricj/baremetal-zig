// This is the public-facing API of the thread module.

// The thread modules handles everything related to threads. This includes
// notably processor exceptions.

const interrupt = @import("interrupt.zig");
const trap = @import("trap.zig");

pub const handleInterrupt = interrupt.handleInterrupt;
pub const handleTrap = trap.handleTrap;
