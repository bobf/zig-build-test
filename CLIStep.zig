const std = @import("std");

const CLIStep = @This();

exe: *std.Build.Step.Compile,
step: std.Build.Step,

pub fn init(build: *std.Build, exe: *std.Build.Step.Compile) CLIStep {
    const step = std.Build.Step.init(.{
        .id = .custom,
        .name = "cli_internal",
        .owner = build,
        .max_rss = 0,
        .makeFn = make,
    });

    const cli_step = build.allocator.create(CLIStep) catch @panic("OOM");
    cli_step.* = .{ .exe = exe, .step = step };

    return .{ .exe = exe, .step = step };
}

fn make(step: *std.Build.Step, progress: *std.Progress.Node) !void {
    const cli_step = @fieldParentPtr(CLIStep, "step", step);
    var node = progress.start("Doing something", 1);
    cli_step.doSomething(step.owner);
    node.end();
}

fn doSomething(cli_step: *const CLIStep, owner: *std.Build) void {
    const write_files = owner.addWriteFiles();
    const lazy_path = write_files.add("foo.zig", "pub const x = 10;");
    const module = owner.createModule(.{ .root_source_file = lazy_path });
    cli_step.exe.root_module.addImport("foo", module);
}
