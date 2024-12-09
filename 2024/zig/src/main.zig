const std = @import("std");
const day1 = @import("day1.zig");

pub fn main() !void {
    std.debug.print("day1: {}\n", .{try day1.result(std.heap.page_allocator)});
}

test {
    _ = @import("day1.zig");
}
