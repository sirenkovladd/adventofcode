const std = @import("std");
const file_contents = @embedFile("assert/day2.txt");

const Direction = enum {
    Empty,
    Inc,
    Dec,
};

const lenListType = u4;
const numType = i8;

const returnType = struct { usize, bool };

fn calculate(comptime parseLine: anytype, input: []const u8) !u16 {
    var numSafeLines: u16 = 0;
    var i: usize = 0;
    while (i < input.len) {
        const res = try parseLine(input, i);
        if (!res[1]) {
            numSafeLines += 1;
        }
        i = res[0] + 1;
    }
    return numSafeLines;
}

fn endOfLine(
    input: []const u8,
    startI: usize,
) returnType {
    var i = startI;
    while (i < input.len and input[i] != '\n') {
        i += 1;
    }
    return .{ i, true };
}

fn isLineValid1(
    input: []const u8,
    startI: usize,
    prevVal: ?numType,
    direction: Direction,
) !returnType {
    if (startI >= input.len or input[startI] == '\n') {
        return .{ startI, false };
    }
    var i = startI;
    while (input[i] == ' ') {
        i += 1;
    }
    const startNumber = i;
    while (i < input.len and '0' - 1 < input[i] and input[i] < '9' + 1) {
        i += 1;
    }
    const value = try std.fmt.parseInt(numType, input[startNumber..i], 10);
    if (prevVal) |v| {
        const diff = @abs(v - value);
        if (diff <= 3) {
            switch (direction) {
                .Empty => {
                    if (v != value) {
                        if (v < value) {
                            return try isLineValid1(input, i, value, .Inc);
                        }
                        return try isLineValid1(input, i, value, .Dec);
                    }
                },
                .Inc => {
                    if (value > v) {
                        return try isLineValid1(input, i, value, .Inc);
                    }
                },
                .Dec => {
                    if (v > value) {
                        return try isLineValid1(input, i, value, .Dec);
                    }
                },
            }
        }
        return endOfLine(input, i);
    }
    return try isLineValid1(input, i, value, direction);
}

fn parseLine1(input: []const u8, startI: usize) !returnType {
    return isLineValid1(input, startI, null, .Empty);
}

fn ss(unstable: ?lenListType, lastValue2: ?numType) bool {
    if (unstable) |_| {
        return true;
    }
    if (lastValue2) |_| {
        return true;
    }
    return false;
}

fn isLineValid2(
    input: []const u8,
    startI: usize,
    count: usize,
    prevVal: ?numType,
    prevVal2: ?numType,
    direction: Direction,
) !returnType {
    if (startI >= input.len or input[startI] == '\n') {
        return .{ startI, false };
    }
    var i = startI;
    while (input[i] == ' ') {
        i += 1;
    }
    const startNumber = i;
    while (i < input.len and '0' - 1 < input[i] and input[i] < '9' + 1) {
        i += 1;
    }
    const value = try std.fmt.parseInt(numType, input[startNumber..i], 10);
    if (prevVal) |v| {
        if (v == value) {
            return try isLineValid1(input, i, v, direction);
        }
        if (@abs(v - value) > 3) {
            const ret = try isLineValid1(input, i, v, direction);
            if (!ret[1]) {
                return ret;
            }
            if (prevVal2) |v2| {
                if (count == 2 and v2 != value and @abs(v2 - value) <= 3) {
                    if (v2 > value and v2 - value <= 3) {
                        return try isLineValid1(input, i, value, .Dec);
                    }
                    if (v2 < value and value - v2 <= 3) {
                        return try isLineValid1(input, i, value, .Inc);
                    }
                }
            } else {
                return try isLineValid1(input, i, value, .Empty);
            }
        } else {
            switch (direction) {
                .Empty => {
                    if (v < value) {
                        return try isLineValid2(input, i, 2, value, v, .Inc);
                    }
                    const vv = try isLineValid2(input, i, 2, value, v, .Dec);
                    return vv;
                },
                .Inc => {
                    if (value > v) {
                        return try isLineValid2(input, i, count + 1, value, v, direction);
                    }
                    const ret = try isLineValid1(input, i, v, direction);
                    if (!ret[1]) {
                        return ret;
                    }
                    if (count == 2) {
                        const ret2 = try isLineValid1(input, i, value, .Dec);
                        if (!ret2[1]) {
                            return ret2;
                        }
                        return try isLineValid1(input, startI, prevVal2, .Empty);
                    }
                },
                .Dec => {
                    if (v > value) {
                        return try isLineValid2(input, i, count + 1, value, v, direction);
                    }
                    const ret = try isLineValid1(input, i, v, direction);
                    if (!ret[1]) {
                        return ret;
                    }
                    if (count == 2) {
                        const ret2 = try isLineValid1(input, i, value, .Inc);
                        if (!ret2[1]) {
                            return ret2;
                        }
                        return try isLineValid1(input, startI, prevVal2, .Empty);
                    }
                },
            }
        }
        return endOfLine(input, i);
    }
    return try isLineValid2(input, i, 1, value, null, direction);
}

fn parseLine2(input: []const u8, startI: usize) !returnType {
    return try isLineValid2(input, startI, 0, null, null, .Empty);
}

pub fn result() !u16 {
    return calculate(parseLine1, file_contents); // 356
}

pub fn result2() !u16 {
    return calculate(parseLine2, file_contents); // 413
}

test "example test1" {
    const expect = std.testing.expect;

    const res = try calculate(parseLine1,
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    );
    try expect(res == 2);
}

test "example test2" {
    const expect = std.testing.expect;

    const res = try calculate(parseLine2,
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    );
    try expect(res == 4);
}

test "example test3" {
    const expect = std.testing.expect;
    const run = struct {
        fn r(str: []const u8) !bool {
            return !(try parseLine2(str, 0))[1];
        }
        fn run(str: []const u8) bool {
            return r(str) catch false;
        }
    }.run;

    try expect(run("3 9"));
    try expect(run("1 2 4"));
    try expect(run("1 2 9"));
    try expect(run("1 2 9 4"));
    try expect(run("1 2 9 4"));
    try expect(run("41 38 40 42 44 47"));

    try expect(!run("1 5 9"));
}

test "example test4" {
    const expect = std.testing.expect;
    const run = struct {
        fn r(str: []const u8) !bool {
            const v = try parseLine2(str, 0);
            return !v[1];
        }
        fn run(str: []const u8) bool {
            return r(str) catch false;
        }
    }.run;

    try expect(run("17 19 17 14 11 10 7 5"));
}
