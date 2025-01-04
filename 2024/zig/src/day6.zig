const std = @import("std");
const file_contents = @embedFile("assert/day6.txt");

const ResultType1 = u16;
const MaxSize = 135;

const Map = struct {
    const Self = @This();
    width: usize,
    map: [MaxSize * MaxSize]bool = [_]bool{false} ** (MaxSize * MaxSize),
    count: ResultType1 = 0,
    fn get(self: *Self, i: usize) bool {
        return self.map[i];
    }
    fn set(self: *Self, i: usize) void {
        if (!self.get(i)) {
            self.map[i] = true;
            self.count += 1;
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

fn calculate1(inp: []const u8) ResultType1 {
    const width = getWidth(inp) + 1;
    std.debug.assert(width <= MaxSize);
    var map = Map{ .width = width };
    var guard = findGuard(inp);
    map.set(guard);
    print_debug("wid {}\n", .{width});
    run: while (true) {
        // ^
        while (true) {
            print_debug("^ {} {} {}\n", .{ guard / width, guard % width, map.count });
            if (guard < width) {
                break :run;
            }
            if (inp[guard - width] == '#') {
                break;
            }
            guard -= width;
            map.set(guard);
        }
        print_debug("\n", .{});
        // >
        while (true) {
            print_debug("> {} {} {}\n", .{ guard / width, guard % width, map.count });
            if (guard % width == width - 1) {
                break :run;
            }
            if (inp[guard + 1] == '#') {
                break;
            }
            guard += 1;
            map.set(guard);
        }
        print_debug("\n", .{});
        // V
        while (true) {
            print_debug("V {} {} {}\n", .{ guard / width, guard % width, map.count });
            if (guard + width > inp.len) {
                break :run;
            }
            if (inp[guard + width] == '#') {
                break;
            }
            guard += width;
            map.set(guard);
        }
        print_debug("\n", .{});
        // <
        while (true) {
            print_debug("< {} {} {}\n", .{ guard / width, guard % width, map.count });
            if (guard % width == 0) {
                break :run;
            }
            if (inp[guard - 1] == '#') {
                break;
            }
            guard -= 1;
            map.set(guard);
        }
        print_debug("\n", .{});
    }
    return map.count;
}

pub fn result1() ResultType1 {
    return calculate1(file_contents); // 5443
}

test "example test1" {
    const expect = std.testing.expectEqual;

    const exmpl1 =
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
    ;

    const res1 = calculate1(exmpl1);
    try expect(41, res1);
}
