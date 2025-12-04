const std = @import("std");
const getTime = std.time.microTimestamp;

const days = .{
    @import("day1.zig"),
};

fn run(comptime day: u8, comptime part: u2, comptime function: anytype, allocator: std.mem.Allocator) void {
    const type_fn = @typeInfo(@TypeOf(function)).@"fn";
    const startTime = getTime();
    if (type_fn.params.len == 0) {
        if (@typeInfo(type_fn.return_type.?) != .int) {
            std.debug.print("day{}.{}: {}, {}μs\n", .{ day, part, function() catch unreachable, getTime() - startTime });
        } else {
            std.debug.print("day{}.{} {}, {}μs\n", .{ day, part, function(), getTime() - startTime });
        }
    } else {
        if (@typeInfo(type_fn.return_type.?) != .int) {
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
        const day_fields = @typeInfo(day).@"struct".decls;
        inline for (day_fields, 1..) |decl, part| {
            run(i, part, @field(day, decl.name), allocator);
        }
    }
}

test {
    _ = days;
}
