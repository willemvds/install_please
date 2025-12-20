const std = @import("std");

const desktop_config = @embedFile("imgpls.desktop");
const imgpls_binary = @embedFile("imgpls");
const scalable_icon = @embedFile("pls.svg");
const icon = @embedFile("128.png");

const ExitCode = enum(u8) {
    Ok = 0,
    Usage = 1,
    Failure = 2,
};

pub fn imgpls(a: std.mem.Allocator) ![]const u8 {
    const install_path = "/usr/bin/imgpls";
    const bin_fh = try std.fs.createFileAbsolute(install_path, .{ .truncate = true, .mode = 0o755 });
    defer bin_fh.close();
    const bin_written = try bin_fh.write(imgpls_binary);
    if (bin_written != imgpls_binary.len) {
        return error.WriteLengthMismatch;
    }

    const desktop_path = "/usr/share/applications/imgpls.desktop";
    const desktop_fh = try std.fs.createFileAbsolute(desktop_path, .{ .truncate = true, .mode = 0o644 });
    defer desktop_fh.close();
    const desktop_written = try desktop_fh.write(desktop_config);
    if (desktop_written != desktop_config.len) {
        return error.WriteLengthMismatch;
    }

    const scalable_icon_path = "/usr/share/icons/hicolor/scalable/apps/imgpls.svg";
    const scalable_icon_fh = try std.fs.createFileAbsolute(scalable_icon_path, .{ .truncate = true, .mode = 0o644 });
    defer scalable_icon_fh.close();
    const scalable_icon_written = try scalable_icon_fh.write(scalable_icon);
    if (scalable_icon_written != scalable_icon.len) {
        return error.WriteLengthMismatch;
    }

    const icon_path = "/usr/share/icons/hicolor/128x128/apps/imgpls.svg";
    const icon_fh = try std.fs.createFileAbsolute(icon_path, .{ .truncate = true, .mode = 0o644 });
    defer icon_fh.close();
    const icon_written = try icon_fh.write(icon);
    if (icon_written != icon.len) {
        return error.WriteLengthMismatch;
    }

    var user: []const u8 = "root";
    const env = try std.process.getEnvMap(a);
    if (env.get("SUDO_USER")) |u| {
        std.debug.print("user = {s}\n", .{u});
        user = u;
    }

    var xdgmime = std.process.Child.init(&[_][]const u8{
        "sudo",
        "-u",
        user,
        "xdg-mime",
        "default",
        "imgpls.desktop",
        "image/png",
    }, a);

    var xdgmime_env = std.process.EnvMap.init(a);
    try xdgmime_env.put("XDG_DEBUG_LEVEL", "3");
    xdgmime.stdin_behavior = .Ignore;
    xdgmime.stdout_behavior = .Pipe;
    xdgmime.stderr_behavior = .Pipe;
    xdgmime.env_map = &xdgmime_env;
    try xdgmime.spawn();
    var stdout = std.ArrayList(u8){};
    var stderr = std.ArrayList(u8){};
    try xdgmime.collectOutput(a, &stdout, &stderr, 1000);
    const exit = try xdgmime.wait();

    if (exit.Exited != @intFromEnum(ExitCode.Ok)) {
        std.debug.print("exit = {any}\n", .{exit});
    }
    if (stdout.items.len > 0) {
        std.debug.print("stdout = {s}\n", .{stdout.items});
    }
    if (stderr.items.len > 0) {
        std.debug.print("stderr = {s}\n", .{stderr.items});
    }

    return install_path;
}
