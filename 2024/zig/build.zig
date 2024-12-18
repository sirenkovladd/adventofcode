const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // add assert files
    var iterator = blk: {
        var assertFolder = std.fs.cwd().openDir("../assert/", .{}) catch unreachable;
        break :blk assertFolder.iterate();
    };
    var cwd_relative: [30]u8 = undefined;
    const assertFolder = "../assert/";
    @memcpy(cwd_relative[0..assertFolder.len], assertFolder);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    while (iterator.next() catch unreachable) |file| {
        if (file.kind == .file) {
            @memcpy(cwd_relative[assertFolder.len .. assertFolder.len + file.name.len], file.name);
            exe.root_module.addAnonymousImport(cwd_relative[3 .. assertFolder.len + file.name.len], .{ .root_source_file = .{ .cwd_relative = cwd_relative[0 .. assertFolder.len + file.name.len] } });
            // exe_unit_tests.root_module.addAnonymousImport(cwd_relative[3 .. assertFolder.len + file.name.len], .{ .root_source_file = .{ .cwd_relative = cwd_relative[0 .. assertFolder.len + file.name.len] } });
        }
    }

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
