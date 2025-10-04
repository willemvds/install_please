const std = @import("std");

const imgpls_binary = @embedFile("imgpls");

pub fn imgpls() ![]const u8 {
    const install_path = "/usr/bin/imgpls";
    const fh = try std.fs.createFileAbsolute(install_path, .{ .truncate = true, .mode = 0o755 });
    const written = try fh.write(imgpls_binary);
    if (written != imgpls_binary.len) {
        return error.WriteLengthMismatch;
    }

    return install_path;
}
