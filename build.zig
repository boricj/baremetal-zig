const std = @import("std");

const arch = std.Target.Cpu.Arch;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    const target_arch = target.cpu_arch orelse @panic("Must specify target architecture with -Dtarget=...");

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("kernel", "src/kernel/main.zig");
    kernel.setBuildMode(mode);
    switch (target_arch) {
        arch.aarch64 => {
            const features = std.Target.aarch64.Feature;
            var target_kernel = target;
            target_kernel.cpu_features_sub.addFeature(@enumToInt(features.neon));
            target_kernel.cpu_features_sub.addFeature(@enumToInt(features.fp_armv8));

            kernel.setTarget(target_kernel);
            kernel.setLinkerScriptPath(.{ .path = "src/kernel/hal/aarch64/linker.ld" });
        },
        else => @panic("Unknown CPU architecture!"),
    }
    kernel.install();

    var run_qemu_args = std.ArrayList([]const u8).init(b.allocator);
    switch (target_arch) {
        arch.aarch64 => run_qemu_args.appendSlice(&[_][]const u8{ "qemu-system-aarch64", "-M", "virt", "-cpu", "cortex-a57" }) catch unreachable,
        else => @panic("Unknown CPU architecture!"),
    }

    run_qemu_args.appendSlice(&[_][]const u8{ "-serial", "stdio" }) catch unreachable;

    const run_qemu = b.addSystemCommand(run_qemu_args.items);
    run_qemu.addArg("-kernel");
    run_qemu.addArtifactArg(kernel);
    run_qemu.step.dependOn(&kernel.step);
    run_qemu.step.dependOn(b.getInstallStep());

    const qemu_step = b.step("qemu", "Run the kernel inside qemu");
    qemu_step.dependOn(&run_qemu.step);

    const run_qemu_debug = b.addSystemCommand(run_qemu_args.items);
    run_qemu_debug.addArg("-s");
    run_qemu_debug.addArg("-S");
    run_qemu_debug.addArg("-kernel");
    run_qemu_debug.addArtifactArg(kernel);
    run_qemu_debug.step.dependOn(&kernel.step);
    run_qemu_debug.step.dependOn(b.getInstallStep());

    const qemu_step_debug = b.step("qemu-debug", "Run the kernel inside qemu, waiting for GDB connection");
    qemu_step_debug.dependOn(&run_qemu_debug.step);
}
