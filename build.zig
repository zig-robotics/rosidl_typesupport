const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Specify static or dynamic linkage") orelse .dynamic;
    const upstream = b.dependency("rosidl_typesupport", .{});

    var rosidl_typesupport_c = std.Build.Step.Compile.create(b, .{
        .root_module = .{
            .target = target,
            .optimize = optimize,
        },
        .name = "rosidl_typesupport_c",
        .kind = .lib,
        .linkage = linkage,
    });

    rosidl_typesupport_c.linkLibCpp();
    rosidl_typesupport_c.addIncludePath(upstream.path("rosidl_typesupport_c/include"));
    rosidl_typesupport_c.addIncludePath(upstream.path("rosidl_typesupport_c/src"));

    const rcutils_dep = b.dependency("rcutils", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    rosidl_typesupport_c.linkLibrary(rcutils_dep.artifact("rcutils"));

    const rcpputils_dep = b.dependency("rcpputils", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    rosidl_typesupport_c.linkLibrary(rcpputils_dep.artifact("rcpputils"));

    const rosidl_dep = b.dependency("rosidl", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });

    rosidl_typesupport_c.linkLibrary(rosidl_dep.artifact("rosidl_runtime_c"));
    rosidl_typesupport_c.addIncludePath(rosidl_dep.builder.dependency("rosidl", .{}).path("rosidl_typesupport_interface/include")); // grab the underlying rosidl dependency for now, until header only libraries are figured out

    rosidl_typesupport_c.addCSourceFiles(.{
        .root = upstream.path("rosidl_typesupport_c"),
        .files = &.{
            "src/identifier.c",
        },
    });

    rosidl_typesupport_c.addCSourceFiles(.{
        .root = upstream.path("rosidl_typesupport_c"),
        .files = &.{
            "src/message_type_support_dispatch.cpp",
            "src/service_type_support_dispatch.cpp",
        },
        .flags = &.{
            "--std=c++17",
        },
    });

    rosidl_typesupport_c.installHeadersDirectory(
        upstream.path("rosidl_typesupport_c/include"),
        "",
        .{},
    );
    b.installArtifact(rosidl_typesupport_c);

    var rosidl_typesupport_cpp = std.Build.Step.Compile.create(b, .{
        .root_module = .{
            .target = target,
            .optimize = optimize,
        },
        .name = "rosidl_typesupport_cpp",
        .kind = .lib,
        .linkage = linkage,
    });

    rosidl_typesupport_cpp.linkLibCpp();
    rosidl_typesupport_cpp.addIncludePath(upstream.path("rosidl_typesupport_cpp/include"));
    rosidl_typesupport_cpp.addIncludePath(upstream.path("rosidl_typesupport_cpp/src"));

    rosidl_typesupport_cpp.linkLibrary(rcutils_dep.artifact("rcutils"));
    rosidl_typesupport_cpp.linkLibrary(rosidl_typesupport_c);
    rosidl_typesupport_cpp.linkLibrary(rcpputils_dep.artifact("rcpputils"));
    rosidl_typesupport_cpp.linkLibrary(rosidl_dep.artifact("rosidl_runtime_c"));
    rosidl_typesupport_cpp.addIncludePath(rosidl_dep.builder.dependency("rosidl", .{}).path("rosidl_typesupport_interface/include")); // grab the underlying rosidl dependency for now, until header only libraries are figured out

    rosidl_typesupport_cpp.addCSourceFiles(.{
        .root = upstream.path("rosidl_typesupport_cpp"),
        .files = &.{
            "src/identifier.cpp",
            "src/message_type_support_dispatch.cpp",
            "src/service_type_support_dispatch.cpp",
        },
        .flags = &.{
            "--std=c++17",
        },
    });

    rosidl_typesupport_cpp.installHeadersDirectory(
        upstream.path("rosidl_typesupport_cpp/include"),
        "",
        .{},
    );
    b.installArtifact(rosidl_typesupport_cpp);
}
