# How to run

## Supported boards

The following boards are supported:

| Target | Boards | Description |
|---|---|---|
| `aarch64-freestanding` | `virt` | QEMU ARM Virtual Machine |

## QEMU

To run HangOS under QEMU, use the `qemu` step:

```sh
zig build -Dtarget=<target> qemu
```

To debug HangOS's kernel under QEMU, use the `qemu-debug` step:

```sh
zig build -Dtarget=<target> qemu-debug
```

The emulation will be paused waiting for a GDB remote connection on local TCP port 1234.
