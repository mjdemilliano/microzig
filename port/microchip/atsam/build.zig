const std = @import("std");
const microzig = @import("microzig/build-internals");

const Self = @This();

chips: struct {
    atsamd51j19: *const microzig.Target,
    atsam3x8e: *const microzig.Target,
},

boards: struct {},

pub fn init(dep: *std.Build.Dependency) Self {
    const b = dep.builder;

    const atpack_dep = b.dependency("atpack", .{});

    const chip_atsamd51j19: microzig.Target = .{
        .dep = dep,
        .preferred_binary_format = .elf,
        .zig_target = .{
            .cpu_arch = .thumb,
            .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
            .cpu_features_add = std.Target.arm.featureSet(&.{.vfp4d16sp}),
            .os_tag = .freestanding,
            .abi = .eabihf,
        },
        .chip = .{
            .name = "ATSAMD51J19A",
            .url = "https://www.microchip.com/en-us/product/ATSAMD51J19A",
            .register_definition = .{
                .atdf = atpack_dep.path("samd51a/atdf/ATSAMD51J19A.atdf"),
            },
            .memory_regions = &.{
                .{ .kind = .flash, .offset = 0x00000000, .length = 512 * 1024 }, // Embedded Flash
                .{ .kind = .ram, .offset = 0x20000000, .length = 192 * 1024 }, // Embedded SRAM
                .{ .kind = .ram, .offset = 0x47000000, .length = 8 * 1024 }, // Backup SRAM
                .{ .kind = .flash, .offset = 0x00804000, .length = 512 }, // NVM User Row
            },
        },
    };

    const chip_atsam3x8e: microzig.Target = .{
        .dep = dep,
        .preferred_binary_format = .elf,
        .zig_target = .{
            .cpu_arch = .thumb,
            .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m3 },
            .cpu_features_add = std.Target.arm.featureSet(&.{.v7m}),
            .os_tag = .freestanding,
            .abi = .eabi,
        },
        .chip = .{
            .name = "ATSAM3X8E",
            .url = "https://www.microchip.com/en-us/product/ATSAM3X8E",
            .register_definition = .{
                .svd = b.path("chips/ATSAM3X8E.svd"),
            },
            .memory_regions = &.{
                .{ .kind = .flash, .offset = 0x00080000, .length = 256 * 1024 }, // Embedded Flash
                .{ .kind = .ram, .offset = 0x20000000, .length = 100 * 1024 }, // Embedded SRAM
            },
        },
        .hal = .{
            .root_source_file = b.path("hals/ATSAM3X8E.zig"),
        },
    };

    return .{
        .chips = .{
            .atsamd51j19 = chip_atsamd51j19.derive(.{}),
            .atsam3x8e = chip_atsam3x8e.derive(.{}),
        },
        .boards = .{},
    };
}

pub fn build(b: *std.Build) void {
    _ = b.step("test", "Run platform agnostic unit tests");
}
