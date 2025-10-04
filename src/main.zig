const std = @import("std");
const install_please = @import("install_please");

pub fn main() !void {
    const installed_path = install_please.imgpls() catch |err| {
        if (err == error.AccessDenied) {
            std.debug.print("\x1B[38;5;196mAccess denied\x1B[0m. Check permissions or use 'sudo' to run as root.\n", .{});
            return;
        }

        return err;
    };

    std.debug.print("ImagePlease installed at \x1B[38;5;214m{s}\x1B[0m.\n", .{installed_path});
}
