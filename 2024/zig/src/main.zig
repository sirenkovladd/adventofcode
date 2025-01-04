const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day7 = @import("day7.zig");

pub fn main() !void {
    var buffer: [1 << 14]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const getTime = std.time.microTimestamp;

    var startTime = getTime();
    std.debug.print("day1.1: {}, {}μs\n", .{ try day1.result(allocator), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day1.2: {}, {}μs\n", .{ try day1.result2(allocator), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day2.1: {}, {}μs\n", .{ try day2.result(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day2.2: {}, {}μs\n", .{ try day2.result2(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day3.1: {}, {}μs\n", .{ day3.result1(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day3.2: {}, {}μs\n", .{ day3.result2(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day4.1: {}, {}μs\n", .{ day4.result1(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day4.2: {}, {}μs\n", .{ day4.result2(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day5.1: {}, {}μs\n", .{ day5.result1(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day5.2: {}, {}μs\n", .{ day5.result2(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day7.1: {}, {}μs\n", .{ day7.result1(), getTime() - startTime });
    startTime = getTime();
    std.debug.print("day7.2: {}, {}μs\n", .{ day7.result2(), getTime() - startTime });
}

test {
    _ = @import("day1.zig");
    _ = @import("day2.zig");
    _ = @import("day3.zig");
    _ = @import("day4.zig");
    _ = @import("day5.zig");
    _ = @import("day7.zig");
}
