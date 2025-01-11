const std = @import("std");
var file_contents = @embedFile("assert/day6.txt").*;

const ResultType1 = u16;
const MaxSize = 135;

const Direction = enum(u4) { Up = 1, Down = 2, Left = 4, Right = 8 };

const Map = struct {
    const Error = error{Loop};
    const Self = @This();
    width: usize,
    map: [MaxSize * MaxSize]u4 = [_]u4{0} ** (MaxSize * MaxSize),
    count: ResultType1 = 0,
    fn set(self: *Self, i: usize, comptime direction: Direction) Error!void {
        // print_debug("map, g:{} m:{} d:{} {}\n", .{ i, self.map[i], @intFromEnum(direction), self.map[i] & @intFromEnum(direction) });
        if (self.map[i] == 0) {
            self.count += 1;
        }
        if (self.map[i] & @intFromEnum(direction) == 0) {
            self.map[i] |= @intFromEnum(direction);
        } else {
            return Error.Loop;
        }
    }
};

fn getWidth(inp: []const u8) usize {
    var i: usize = 0;
    while (inp[i] != '\n') : (i += 1) {}
    return i;
}

fn findGuard(inp: []const u8) usize {
    var i: usize = 0;
    while (inp[i] != '^') : (i += 1) {}
    return i;
}

const print_enable = false;
const print_debug = if (print_enable) std.debug.print else struct {
    fn print(comptime _: []const u8, _: anytype) void {}
}.print;

// day6.1 6040, 130μs
// day6.2 6040, 108μs

fn run_loop(inp: []const u8, map: *Map, guard: *usize, comptime direction: Direction) ?ResultType1 {
    print_debug("point inp : {*}, dir : {}\n", .{ map, direction });
    const step = switch (direction) {
        .Right, .Left => 1,
        .Up, .Down => map.width,
    };
    const positive = switch (direction) {
        .Right, .Down => true,
        .Up, .Left => false,
    };
    while (true) {
        if (direction == .Up and guard.* < map.width) {
            return map.count + 1;
        }
        if (direction == .Right and guard.* % map.width == map.width - 1) {
            return map.count + 1;
        }
        if (direction == .Down and guard.* + map.width > inp.len) {
            return map.count + 1;
        }
        if (direction == .Left and guard.* % map.width == 0) {
            return map.count + 1;
        }
        if ((positive and inp[guard.* + step] == '#') or (!positive and inp[guard.* - step] == '#')) {
            const next_direction = switch (direction) {
                .Up => .Right,
                .Right => .Down,
                .Down => .Left,
                .Left => .Up,
            };
            return run_loop(inp, map, guard, next_direction);
        }
        map.set(guard.*, direction) catch return null;
        // print_debug("{s} {} {} {}\n", .{ @tagName(direction), guard.* / map.width, guard.* % map.width, map.count });
        if (positive) {
            guard.* += step;
        } else {
            guard.* -= step;
        }
    }
}

var map_gl: Map = undefined;

fn run_loop2(inp: []u8, map: *Map, guard: *usize, comptime direction: Direction, used_cell: []bool) ResultType1 {
    var count_loops: ResultType1 = 0;
    const step = switch (direction) {
        .Right, .Left => 1,
        .Up, .Down => map.width,
    };
    const positive = switch (direction) {
        .Right, .Down => true,
        .Up, .Left => false,
    };
    while (true) {
        if (direction == .Up and guard.* < map.width) {
            return count_loops;
        }
        if (direction == .Right and guard.* % map.width == map.width - 1) {
            return count_loops;
        }
        if (direction == .Down and guard.* + map.width > inp.len) {
            return count_loops;
        }
        if (direction == .Left and guard.* % map.width == 0) {
            return count_loops;
        }
        const next_direction = comptime switch (direction) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
        };
        if ((positive and inp[guard.* + step] == '#') or (!positive and inp[guard.* - step] == '#')) {
            return count_loops + run_loop2(inp, map, guard, next_direction, used_cell);
        }
        map.set(guard.*, direction) catch unreachable;
        print_debug("{s} {} {} {}\n", .{ @tagName(direction), guard.* / map.width, guard.* % map.width, map.count });
        var prev_guard = guard.*;

        if (positive) {
            guard.* += step;
        } else {
            guard.* -= step;
        }

        if (!used_cell[guard.*]) {
            inp[guard.*] = '#';
            map_gl = map.*;
            if (run_loop(inp, &map_gl, &prev_guard, next_direction) == null) {
                count_loops += 1;
                print_debug("loop {}\n", .{count_loops});
            }
            inp[guard.*] = '.';
            used_cell[guard.*] = true;
        }
    }
}

fn calculate1(inp: []const u8) ResultType1 {
    const width = getWidth(inp) + 1;
    std.debug.assert(width <= MaxSize);
    var map = Map{ .width = width };
    var guard = findGuard(inp);
    return run_loop(inp, &map, &guard, .Up) orelse map.count;
}

fn calculate2(inp: []u8, used_cell: []bool) ResultType1 {
    const width = getWidth(inp) + 1;
    std.debug.assert(width <= MaxSize);
    var map = Map{ .width = width };
    var guard = findGuard(inp);
    used_cell[guard] = true;
    return run_loop2(inp, &map, &guard, .Up, used_cell);
}

pub fn result1() ResultType1 {
    return calculate1(&file_contents); // 5443
}

pub fn result2() ResultType1 {
    var used_cell = [_]bool{false} ** (MaxSize * MaxSize);
    return calculate2(&file_contents, &used_cell); // 1946
}

test "example test1" {
    const expect = std.testing.expectEqual;

    var exmpl1 =
        (
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ).*;

    const res1 = calculate1(&exmpl1);
    try expect(41, res1);

    var used_cell = [_]bool{false} ** (MaxSize * MaxSize);
    const res2 = calculate2(&exmpl1, &used_cell);
    try expect(6, res2);
}
