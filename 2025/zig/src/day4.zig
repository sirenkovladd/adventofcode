const std = @import("std");

var file_contents = @embedFile("assert/day4.txt").*;

const Result = u64;
const possibleNeighbors = 4;

fn checkBorder(comptime needToRemove: bool, comptime reverse: bool, begin: usize, step: usize, sideStep: usize, max: usize, input: if (needToRemove) []u8 else []const u8) Result {
    var res: Result = 0;
    for (1..max - 1) |i| {
        const pos = begin + i * step;
        // std.debug.print("{} {c}\n", .{ pos, input[pos] });
        if (input[pos] == '@') {
            var count: u8 = 0;
            if (input[pos - step] == '@') {
                count += 1;
            }
            if (input[(if (!reverse) pos + sideStep else pos - sideStep) - step] == '@') {
                count += 1;
            }
            if (input[if (!reverse) pos + sideStep else pos - sideStep] == '@') {
                count += 1;
            }
            if (input[pos + step] == '@') {
                count += 1;
            }
            if (input[(if (!reverse) pos + sideStep else pos - sideStep) + step] == '@') {
                count += 1;
            }
            if (count < possibleNeighbors) {
                if (needToRemove) {
                    input[pos] = '.';
                }
                // std.debug.print(">{} {}\n", .{ pos, count });
                res += 1;
            }
        }
    }
    return res;
}

fn checkFrame(comptime needToRemove: bool, sizeRow: usize, size: usize, input: if (needToRemove) []u8 else []const u8) Result {
    var res: Result = 0;

    // First horizontal
    res += checkBorder(needToRemove, false, 0, 1, sizeRow, sizeRow - 1, input);
    // last horizontal
    res += checkBorder(needToRemove, true, sizeRow * size, 1, sizeRow, sizeRow - 1, input);
    // First vertical
    res += checkBorder(needToRemove, false, 0, sizeRow, 1, size + 1, input);
    // last vertical
    res += checkBorder(needToRemove, true, sizeRow - 2, sizeRow, 1, size + 1, input);

    // check corners
    inline for (.{ 0, size }) |j| {
        inline for (.{ 0, sizeRow - 2 }) |i| {
            const pos = j * sizeRow + i;
            // std.debug.print("{} {c}\n", .{ pos, input[pos] });
            if (input[pos] == '@') {
                var count: u8 = 0;
                if (i > 0) {
                    if (input[pos - 1] == '@') {
                        count += 1;
                    }
                } else {
                    if (input[pos + 1] == '@') {
                        count += 1;
                    }
                }
                if (j > 0) {
                    if (input[pos - sizeRow] == '@') {
                        count += 1;
                    }
                } else {
                    if (input[pos + sizeRow] == '@') {
                        count += 1;
                    }
                }
                if (count < possibleNeighbors) {
                    if (needToRemove) {
                        input[pos] = '.';
                    }
                    // std.debug.print("{} {}\n", .{ j, i });
                    res += 1;
                }
            }
        }
    }
    return res;
}

fn calculate(comptime needToRemove: bool, input: if (needToRemove) []u8 else []const u8) Result {
    var res: Result = 0;
    const sizeRow = (std.mem.indexOfScalarPos(u8, input, 0, '\n') orelse unreachable) + 1;
    const size = input.len / sizeRow;

    // First horizontal
    res += checkFrame(needToRemove, sizeRow, size, input);
    // std.debug.print("res={}\n", .{res});

    // std.debug.print("size={} sizeRow={}\n", .{ size, sizeRow });
    for (1..sizeRow - 2) |i| {
        for (1..size) |j| {
            const pos = j * sizeRow + i;
            // std.debug.print("{} {c} {} {}\n", .{ pos, input[pos], j, i });
            if (input[pos] == '@') {
                var count: u8 = 0;
                inline for (.{ 0, 1, 2 }) |dj| {
                    inline for (.{ 0, 1, 2 }) |di| {
                        if (di == 1 and dj == 1) continue;
                        if (input[(j + dj - 1) * sizeRow + i + di - 1] == '@') {
                            count += 1;
                        }
                    }
                }
                if (count < possibleNeighbors) {
                    if (needToRemove) {
                        input[pos] = '.';
                    }
                    // std.debug.print("{} {}\n", .{ j, i });
                    res += 1;
                }
            }
        }
    }
    return res;
}

pub fn result1() Result {
    return calculate(false, &file_contents); // 1578
}

pub fn result2() Result {
    var result: Result = 0;
    while (true) {
        const count = calculate(true, &file_contents);
        if (count == 0) break;
        result += count;
    }
    return result; // 10132
}

const test_example =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

test "example test 1" {
    const expect = std.testing.expectEqual;

    const sizeRow = (std.mem.indexOfScalarPos(u8, test_example, 0, '\n') orelse unreachable) + 1;
    const size = test_example.len / sizeRow;

    try expect(5, checkBorder(false, false, 0, 1, sizeRow, sizeRow - 1, test_example));
    try expect(2, checkBorder(false, true, sizeRow * size, 1, sizeRow, sizeRow - 1, test_example));
    try expect(3, checkBorder(false, false, 0, sizeRow, 1, size + 1, test_example));
    try expect(1, checkBorder(false, true, sizeRow - 2, sizeRow, 1, size + 1, test_example));
    try expect(12, checkFrame(false, sizeRow, size, test_example));
    try expect(13, calculate(false, test_example));
}

test "example test 2" {
    const expect = std.testing.expectEqual;

    var test_example1 = test_example.*;
    try expect(39, calculate(true, test_example1[0..]));
    try expect(3, calculate(true, test_example1[0..]));
}
