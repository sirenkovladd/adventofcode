const std = @import("std");
const file_contents = @embedFile("assert/day8.txt");

const ReturnType = u16;

fn getWidth(inp: []const u8) usize {
    var i: usize = 0;
    while (inp[i] != '\n') : (i += 1) {}
    return i;
}

const AntinodesManager = struct {
    const Self = @This();

    list_antinodes: [3000]bool = [_]bool{false} ** 3000,
    result: ReturnType = 0,

    fn addAntinode(self: *Self, i: usize, ant: usize, width: usize) void {
        const x1 = i % width;
        const x2 = ant % width;
        if (if (x1 <= x2) 2 * x2 - x1 < width - 1 else 2 * x2 >= x1) {
            const ai = 2 * ant - i;
            if (!self.list_antinodes[ai]) {
                self.list_antinodes[ai] = true;
                self.result += 1;
            }
        }
    }
};

const ListAntennas = struct {
    const Self = @This();
    const size = 10;
    frequency: u8,
    list: [size]usize,
    n: u8,
};

fn calculate1(inp: []const u8) ReturnType {
    const width = getWidth(inp) + 1;
    var list_antennas: [60]ListAntennas = undefined;
    var n: u8 = 0;

    var antinodes_manager = AntinodesManager{};

    for (inp, 0..) |c, i| {
        if (c != '.' and c != '\n') {
            for (list_antennas[0..n]) |*lant| {
                if (lant.frequency == c) {
                    for (lant.list[0..lant.n]) |ant| {
                        // std.debug.print("= => {} {} % {}\n", .{ ant % width, i % width, width });
                        if (i <= 2 * ant) {
                            antinodes_manager.addAntinode(i, ant, width);
                        }
                        if (2 * i - ant < inp.len) {
                            antinodes_manager.addAntinode(ant, i, width);
                        }
                    }
                    lant.list[lant.n] = i;
                    lant.n += 1;
                    std.debug.assert(lant.n < lant.list.len);
                    break;
                }
            } else {
                list_antennas[n] = ListAntennas{
                    .frequency = c,
                    .list = [_]usize{i} ++ ([_]usize{0} ** (ListAntennas.size - 1)),
                    .n = 1,
                };
                n += 1;
            }
            // std.debug.print("{} {c} {}\n", .{ i, c, n });
            std.debug.assert(n < list_antennas.len);
        }
    }
    return antinodes_manager.result;
}

pub fn result1() ReturnType {
    // var file_contents1 = file_contents.*;
    return calculate1(file_contents); // 341
}

test "example test1" {
    const expect = std.testing.expectEqual;

    const exmpl =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;

    // var exmpl1 = exmpl.*;
    const res1 = calculate1(exmpl);
    try expect(14, res1);
}

test "example test2" {
    const expect = std.testing.expectEqual;

    const exmpl =
        \\..........
        \\..........
        \\..........
        \\....a.....
        \\........a.
        \\.....a....
        \\..........
        \\..........
        \\..........
        \\..........
    ;

    // var exmpl1 = exmpl.*;
    const res1 = calculate1(exmpl);
    try expect(4, res1);
}

test "example test3" {
    const expect = std.testing.expectEqual;

    const exmpl =
        \\..........
        \\..........
        \\..........
        \\....a.....
        \\........a.
        \\.....a....
        \\..........
        \\......A...
        \\..........
        \\..........
    ;

    // var exmpl1 = exmpl.*;
    const res1 = calculate1(exmpl);
    try expect(4, res1);
}

test "example test4" {
    const expect = std.testing.expectEqual;

    const exmpl =
        \\8.........
        \\.....8....
        \\..........
        \\..........
    ;

    const res1 = calculate1(exmpl);
    try expect(0, res1);

    const exmpl2 =
        \\..........
        \\..........
        \\6.........
        \\.....6....
    ;

    const res2 = calculate1(exmpl2);
    try expect(0, res2);
}
