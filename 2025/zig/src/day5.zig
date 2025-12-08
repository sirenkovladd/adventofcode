const std = @import("std");

const file_contents = @embedFile("assert/day5.txt");
const maxRanges = q: {
    @setEvalBranchQuota(100000);
    var i: usize = 0;
    var lineIt = std.mem.splitScalar(u8, file_contents, '\n');
    while (lineIt.next()) |line| {
        if (line.len == 0) break;
        i += 1;
    }
    break :q i;
};

const Result = u64;
const possibleNeighbors = 4;

const RangeType = u64;
const Range = struct {
    from: RangeType,
    to: RangeType,
};

fn optimizeRanges(ranges: []Range) usize {
    var i: usize = ranges.len;
    var j: usize = 0;
    while (j < i) : (j += 1) {
        var smaller = j;
        for (j + 1..i) |k| {
            if (ranges[k].from < ranges[smaller].from) {
                smaller = k;
            }
        }
        if (j > 0 and ranges[j - 1].to >= ranges[j].from) {
            ranges[j - 1].to = @max(ranges[j - 1].to, ranges[j].to);
            ranges[j] = ranges[i - 1];
            i -= 1;
        } else if (smaller != j) {
            std.mem.swap(Range, &ranges[j], &ranges[smaller]);
        }
    }
    return i;
}

fn inAnyRange(value: RangeType, ranges: []const Range) bool {
    for (ranges) |range| {
        if (value >= range.from and value <= range.to) {
            return true;
        }
    }
    return false;
}

fn getRanges(it: *std.mem.SplitIterator(u8, .scalar), ranges: []Range) []Range {
    var i: usize = 0;

    // parse ranges
    while (it.next()) |line| {
        if (line.len == 0) break;
        var range = std.mem.tokenizeScalar(u8, line, '-');
        ranges[i] = .{
            .from = std.fmt.parseInt(RangeType, range.next() orelse unreachable, 10) catch unreachable,
            .to = std.fmt.parseInt(RangeType, range.next() orelse unreachable, 10) catch unreachable,
        };
        i += 1;
    }
    // printRanges(ranges[0..i]);
    i = optimizeRanges(ranges[0..i]);
    // printRanges(ranges[0..i]);
    return ranges[0..i];
}

fn calculate(comptime max: usize, input: []const u8) Result {
    var ranges: [max]Range = undefined;
    var lineIt = std.mem.splitScalar(u8, input, '\n');
    const parsedRanges = getRanges(&lineIt, &ranges);

    var res: Result = 0;
    while (lineIt.next()) |line| {
        const value = std.fmt.parseInt(RangeType, line, 10) catch unreachable;
        if (inAnyRange(value, parsedRanges)) {
            res += 1;
        }
    }
    return res;
}

fn calculate2(comptime max: usize, input: []const u8) Result {
    var ranges: [max]Range = undefined;
    var lineIt = std.mem.splitScalar(u8, input, '\n');
    const parsedRanges = getRanges(&lineIt, &ranges);

    var res: Result = 0;
    for (parsedRanges) |range| {
        res += range.to - range.from;
    }
    return res;
}

pub fn result1() Result {
    return calculate(maxRanges, file_contents); // 865
}

pub fn result2() Result {
    return calculate2(maxRanges, file_contents); // 352556672963116
}

const test_example =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

test "example test 1" {
    const expect = std.testing.expectEqual;

    try expect(3, calculate(4, test_example));
}

test "example test 2" {
    const expect = std.testing.expectEqual;
    try expect(14, calculate2(4, test_example));
}
