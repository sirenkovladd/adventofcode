const std = @import("std");

const file_contents = @embedFile("assert/day2.txt");

const Result = u64;

var inputNum: [10]u4 = undefined;

fn printInt(buffer: []u4, pos: Result) usize {
    var i: usize = 0;
    var pos2 = pos;
    while (pos2 > 0) : (i += 1) {
        buffer[i] = @intCast(pos2 % 10);
        pos2 /= 10;
    }
    return i;
}

fn process1(buffer: []u4) bool {
    if (buffer.len % 2 == 1) {
        return false;
    }
    const half = buffer.len / 2;
    for (0..half) |i| {
        if (buffer[i] != buffer[half + i]) {
            return false;
        }
    }
    return true;
}
fn process2(buffer: []u4) bool {
    start: for (1..buffer.len / 2 + 1) |len| {
        if (@mod(buffer.len, len) != 0) {
            continue;
        }
        for (0..len) |i| {
            for (0..buffer.len / len - 1) |j| {
                if (buffer[i + j * len] != buffer[i + (j + 1) * len]) {
                    continue :start;
                }
            }
        }
        return true;
    }
    return false;
}

fn calculateRange(comptime process: fn ([]u4) bool, from: Result, to: Result) Result {
    var res: Result = 0;
    var i = from;
    while (i <= to) : (i += 1) {
        const buffer = printInt(inputNum[0..], i);
        if (process(inputNum[0..buffer])) {
            res += i;
        }
    }
    return res;
}

fn calculate(comptime process: fn ([]u4) bool, input: []const u8) !Result {
    var res: Result = 0;
    var rangeIt = std.mem.tokenizeScalar(u8, input, ',');
    while (rangeIt.next()) |range| {
        var numIt = std.mem.tokenizeScalar(u8, range, '-');
        const from = std.fmt.parseUnsigned(Result, numIt.next() orelse unreachable, 10) catch unreachable;
        const to = std.fmt.parseUnsigned(Result, numIt.next() orelse unreachable, 10) catch unreachable;
        res += calculateRange(process, from, to);
    }

    return res;
}

pub fn result1() !Result {
    return calculate(process1, file_contents); // 20223751480
}

pub fn result2() !Result {
    return calculate(process2, file_contents); // 30260171216
}

const test_example =
    \\11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
;

test "example test 1" {
    const expect = std.testing.expectEqual;

    const res = try calculate(process1, test_example);
    try expect(1227775554, res);
}

test "example test 2" {
    const expect = std.testing.expectEqual;

    const res = try calculate(process2, test_example);
    try expect(4174379265, res);
}
