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

    fn addAntinode(self: *Self, pos: usize) void {
        if (!self.list_antinodes[pos]) {
            self.list_antinodes[pos] = true;
            self.result += 1;
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

fn calculate(inp: []const u8, comptime is_harmonics: bool) ReturnType {
    const width = getWidth(inp) + 1;
    var list_antennas: [60]ListAntennas = undefined;
    var n: u8 = 0;

    var antinodes_manager = AntinodesManager{};

    for (inp, 0..) |c, i| {
        if (c != '.' and c != '\n') {
            for (list_antennas[0..n]) |*lant| {
                if (lant.frequency == c) {
                    for (lant.list[0..lant.n]) |ant| {
                        const diff = i - ant;
                        const i_x = i % width;
                        const ant_x = ant % width;
                        if (is_harmonics) {
                            antinodes_manager.addAntinode(ant);
                            antinodes_manager.addAntinode(i);
                            var next = ant;
                            var x_pos = ant_x;
                            if (i_x >= x_pos) {
                                const diffx = i_x - x_pos;
                                while (next >= diff and x_pos >= diffx) {
                                    next -= diff;
                                    x_pos -= diffx;
                                    antinodes_manager.addAntinode(next);
                                }
                                next = i;
                                x_pos = i_x;
                                while (next + diff < inp.len and x_pos + diffx < width - 1) {
                                    next += diff;
                                    x_pos += diffx;
                                    antinodes_manager.addAntinode(next);
                                }
                            } else {
                                const diffx = x_pos - i_x;
                                while (next >= diff and x_pos + diffx < width - 1) {
                                    next -= diff;
                                    x_pos += diffx;
                                    antinodes_manager.addAntinode(next);
                                }
                                next = i;
                                x_pos = i_x;
                                while (next + diff < inp.len and x_pos >= diffx) {
                                    next += diff;
                                    x_pos -= diffx;
                                    antinodes_manager.addAntinode(next);
                                }
                            }
                        } else {
                            if (ant >= diff and (if (i_x >= ant_x) 2 * ant_x >= i_x else 2 * ant_x + 1 < i_x + width)) {
                                antinodes_manager.addAntinode(ant - diff);
                            }
                            if (i + diff < inp.len and (if (i_x >= ant_x) 2 * i_x + 1 < width + ant_x else 2 * i_x >= ant_x)) {
                                antinodes_manager.addAntinode(i + diff);
                            }
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
            std.debug.assert(n < list_antennas.len);
        }
    }
    return antinodes_manager.result;
}

pub fn result1() ReturnType {
    return calculate(file_contents, false); // 341
}

pub fn result2() ReturnType {
    return calculate(file_contents, true); // 1134
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

    const res1 = calculate(exmpl, false);
    try expect(14, res1);

    const res2 = calculate(exmpl, true);
    try expect(34, res2);
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

    const res1 = calculate(exmpl, false);
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

    const res1 = calculate(exmpl, false);
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

    const res1 = calculate(exmpl, false);
    try expect(0, res1);

    const exmpl2 =
        \\..........
        \\..........
        \\6.........
        \\.....6....
    ;

    const res2 = calculate(exmpl2, false);
    try expect(0, res2);
}

test "example test5" {
    const expect = std.testing.expectEqual;

    const exmpl =
        \\T.........
        \\...T......
        \\.T........
        \\..........
        \\..........
        \\..........
        \\..........
        \\..........
        \\..........
        \\..........
    ;

    const res1 = calculate(exmpl, true);
    try expect(9, res1);
}

test "example test6" {
    const expect = std.testing.expectEqual;

    const exmpl =
        \\...........
        \\...........
        \\...........
        \\........0..
        \\.......0...
        \\...........
        \\...........
    ;

    const res1 = calculate(exmpl, true);
    try expect(6, res1);
}
