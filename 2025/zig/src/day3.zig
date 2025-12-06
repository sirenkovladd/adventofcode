const std = @import("std");

const file_contents = @embedFile("assert/day3.txt");

const Result = u64;

fn process(comptime len: u8, batteries: []const u8) Result {
    var maxVoltage: [len]u8 = @splat(0);

    var i: usize = 0;
    for (batteries[0..batteries.len], 0..) |voltage, j| {
        const startFrom = if (j + len < batteries.len) 0 else j + len - batteries.len;
        for (startFrom..len) |k| {
            if (voltage > maxVoltage[k]) {
                maxVoltage[k] = voltage;
                while (i > k + 1) : (i -= 1) {
                    maxVoltage[i - 1] = 0;
                }
                i = k + 1;

                break;
            }
        }
    }

    var result: Result = 0;
    for (maxVoltage[0..len]) |voltage| {
        result = result * 10 + voltage - '0';
    }
    return result;
}

fn calculate(comptime len: u8, input: []const u8) Result {
    var res: Result = 0;
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |bank| {
        res += process(len, bank);
    }

    return res;
}

pub fn result1() !Result {
    return calculate(2, file_contents); // 16842
}

pub fn result2() !Result {
    return calculate(12, file_contents); // 167523425665348
}

const test_example =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

test "example test 1" {
    const expect = std.testing.expectEqual;
    const len = 2;

    var lineIt = std.mem.tokenizeScalar(u8, test_example, '\n');
    try expect(98, process(len, lineIt.next() orelse unreachable));
    try expect(89, process(len, lineIt.next() orelse unreachable));
    try expect(78, process(len, lineIt.next() orelse unreachable));
    try expect(92, process(len, lineIt.next() orelse unreachable));
    try expect(357, calculate(len, test_example));
}

test "example test 2" {
    const expect = std.testing.expectEqual;
    const len = 12;

    var lineIt = std.mem.tokenizeScalar(u8, test_example, '\n');
    try expect(987654321111, process(len, lineIt.next() orelse unreachable));
    try expect(811111111119, process(len, lineIt.next() orelse unreachable));
    try expect(434234234278, process(len, lineIt.next() orelse unreachable));
    try expect(888911112111, process(len, lineIt.next() orelse unreachable));
    try expect(3121910778619, calculate(len, test_example));
}
