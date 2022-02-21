# How to build

## Prerequisites

Building HangOS requires the following dependencies:
* A [Zig](https://ziglang.org/) toolchain (version 0.9.0 or better)

## Supported targets

The following targets are supported:
* `aarch64-freestanding`: ARMv8 (64-bit only)

## Build

To build HangOS, use the default step:

```sh
zig build -Dtarget=<target>
```

## Then what?

Once the operating system is built, the next step is to [run HangOS](HowToRun.md).
