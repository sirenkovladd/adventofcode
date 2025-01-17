const std = @import("std");
const days = .{
    @import("day1.zig"),
    @import("day2.zig"),
    @import("day3.zig"),
    @import("day4.zig"),
    @import("day5.zig"),
    @import("day6.zig"),
    @import("day7.zig"),
    @import("day8.zig"),
    @import("day9.zig"),
};

const getTime = std.time.microTimestamp;

fn run(comptime day: u8, comptime part: u2, comptime function: anytype, allocator: std.mem.Allocator) void {
    const type_fn = @typeInfo(@TypeOf(function)).Fn;
    const startTime = getTime();
    if (type_fn.params.len == 0) {
        if (@typeInfo(type_fn.return_type.?) != .Int) {
            std.debug.print("day{}.{}: {}, {}μs\n", .{ day, part, function() catch unreachable, getTime() - startTime });
        } else {
            std.debug.print("day{}.{} {}, {}μs\n", .{ day, part, function(), getTime() - startTime });
        }
    } else {
        if (@typeInfo(type_fn.return_type.?) != .Int) {
            std.debug.print("day{}.{} {}, {}μs\n", .{ day, part, function(allocator) catch unreachable, getTime() - startTime });
        } else {
            std.debug.print("day{}.{} {}, {}μs\n", .{ day, part, function(allocator), getTime() - startTime });
        }
    }
}

pub fn main() !void {
    var buffer: [1 << 14]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    inline for (days, 1..) |day, i| {
        const day_fields = @typeInfo(day).Struct.decls;
        inline for (day_fields, 1..) |decl, part| {
            run(i, part, @field(day, decl.name), allocator);
        }
    }
}

test {
    _ = days;
}
