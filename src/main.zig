const std = @import("std");
const install_please = @import("install_please");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var ally = gpa.allocator();

pub fn main() !void {
    const installed_path = install_please.imgpls(ally) catch |err| {
        switch (err) {
            error.AccessDenied => {
                std.debug.print("\x1B[38;5;196mAccess denied\x1B[0m. Check permissions or use 'sudo' to run as root.\n", .{});
                return;
            },
            error.WriteLengthMismatch => {
                std.debug.print("\x1B[38;5;196mWrite Length Mismatch\x1B[0m. Possible that written binary is corrupted. Please try running install again.\n", .{});
                return;
            },
            else => {
                return err;
            },
        }
        if (err == error.AccessDenied) {
            return;
        }

        return err;
    };

    std.debug.print("ImagePlease installed at \x1B[38;5;214m{s}\x1B[0m.\n", .{installed_path});
}
