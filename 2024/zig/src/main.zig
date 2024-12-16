const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");

pub fn main() !void {
    std.debug.print("day1.1: {}\n", .{try day1.result(std.heap.page_allocator)});
    std.debug.print("day1.2: {}\n", .{try day1.result2(std.heap.page_allocator)});
    std.debug.print("day2.1: {}\n", .{try day2.result()});
    std.debug.print("day2.2: {}\n", .{try day2.result2()});
}

test {
    _ = @import("day1.zig");
    _ = @import("day2.zig");
}
