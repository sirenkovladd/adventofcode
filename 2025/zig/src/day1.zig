const std = @import("std");

const file_contents = @embedFile("assert/day1.txt");

const Position = i16;

const ProcessResult = struct { clicks: u32, newPos: Position };

const DialSize = 100;

fn process1(pos: Position, step: Position) ProcessResult {
    const n = @mod(pos + step, DialSize);
    return if (n == 0) .{ .clicks = 1, .newPos = n } else .{ .clicks = 0, .newPos = n };
}

fn process2(pos: Position, step: Position) ProcessResult {
    var n = pos + step;
    var clicks: u32 = 0;
    if (step > 0) {
        while (n >= DialSize) {
            n -= DialSize;
            clicks += 1;
        }
    } else {
        while (n < 0) {
            n += DialSize;
            clicks += 1;
        }
        if (n == 0) {
            clicks += 1;
        }
        if (pos == 0) {
            clicks -= 1;
        }
    }
    return .{ .clicks = clicks, .newPos = n };
}

fn calculate(process: fn (Position, Position) ProcessResult, startPos: Position, input: []const u8) !u32 {
    var res: u32 = 0;
    var pos: Position = startPos;
    var it = std.mem.TokenIterator(u8, .scalar){ .buffer = input, .delimiter = '\n', .index = 0 };
    while (it.next()) |token| {
        var step: Position = undefined;
        if (token[0] == 'L') {
            step = -(std.fmt.parseUnsigned(Position, token[1..], 10) catch unreachable);
        } else {
            step = (std.fmt.parseUnsigned(Position, token[1..], 10) catch unreachable);
        }
        const val = process(pos, step);
        res += val.clicks;
        pos = val.newPos;
    }

    return res;
}

pub fn result1() !u32 {
    return calculate(process1, 50, file_contents); // 1007
}

pub fn result2() !u32 {
    return calculate(process2, 50, file_contents); // 5820
}

const test_example =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

test "example test 1" {
    const expect = std.testing.expectEqual;

    const res = try calculate(process1, 50, test_example);
    try expect(res, 3);
}

test "example test 2" {
    const expect = std.testing.expectEqual;

    const res = try calculate(process2, 50, test_example);
    try expect(res, 6);
}

test "example test 3" {
    const expect = std.testing.expectEqual;

    try expect(10, try calculate(process2, 50, "L1000"));
    try expect(10, try calculate(process2, 50, "R1000"));
    try expect(1, try calculate(process2, 0, "L101"));
    try expect(1, try calculate(process2, 0, "R101"));
    try expect(2, try calculate(process2, 50, "L150"));
    try expect(2, try calculate(process2, 50, "R150"));
    try expect(1, try calculate(process2, 50, "L50"));
    try expect(1, try calculate(process2, 50, "L50\nL1"));
    try expect(2, try calculate(process2, 50, "L50\nL1\nR100"));
}
