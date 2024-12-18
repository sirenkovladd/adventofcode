const std = @import("std");
const file_contents = @embedFile("assert/day3.txt");

const ResultType1 = u32;

fn parseMul(inp: []const u8, _i: usize) struct { sum: ResultType1, endI: usize } {
    var i = _i;
    const startV1 = i;
    while (i < inp.len and '0' - 1 < inp[i] and inp[i] < '9' + 1) {
        i += 1;
    }
    if (i == inp.len or inp[i] != ',') {
        return .{ .sum = 0, .endI = i };
    }
    const endV1 = i;
    i += 1;
    const startV2 = i;
    while (i < inp.len and '0' - 1 < inp[i] and inp[i] < '9' + 1) {
        i += 1;
    }
    if (i == inp.len or inp[i] != ')') {
        return .{ .sum = 0, .endI = i };
    }
    const endV2 = i;

    const v1 = std.fmt.parseInt(ResultType1, inp[startV1..endV1], 10) catch unreachable;
    const v2 = std.fmt.parseInt(ResultType1, inp[startV2..endV2], 10) catch unreachable;

    return .{ .sum = v1 * v2, .endI = i };
}

const match = "mul(";
const matchDo = "do()";
const matchDont = "don't()";

fn calculate(inp: []const u8) ResultType1 {
    var result: ResultType1 = 0;
    var i: usize = 0;
    var state: u4 = 0;
    while (i < inp.len) : (i += 1) {
        switch (state) {
            0 => {},
            match.len => {
                const res = parseMul(inp, i);
                result += res.sum;
                i = res.endI;
            },
            else => {
                if (inp[i] == match[state]) {
                    state += 1;
                    continue;
                }
            },
        }
        state = if (inp[i] == match[0]) 1 else 0;
    }
    return result;
}

fn calculate2(inp: []const u8) ResultType1 {
    var result: ResultType1 = 0;
    var i: usize = 0;
    var state: u4 = 0;
    var enabled = true;
    while (i < inp.len) : (i += 1) {
        if (state > match.len) {
            if (enabled) {
                if (state - match.len == matchDont.len) {
                    enabled = false;
                }
                if (inp[i] == matchDont[state - match.len]) {
                    state += 1;
                    continue;
                }
            } else {
                if (state - match.len == matchDo.len) {
                    enabled = true;
                }
                if (inp[i] == matchDo[state - match.len]) {
                    state += 1;
                    continue;
                }
            }
        } else if (enabled and state > 0) {
            if (state == match.len) {
                const res = parseMul(inp, i);
                result += res.sum;
                i = res.endI;
            }
            if (inp[i] == match[state]) {
                state += 1;
                continue;
            }
        }
        state = if (inp[i] == match[0]) 1 else if (inp[i] == matchDo[0]) match.len + 1 else 0;
    }
    return result;
}

pub fn result1() ResultType1 {
    return calculate(file_contents); // 184576302
}

pub fn result2() ResultType1 {
    return calculate2(file_contents); // 118173507
}

test "example test1" {
    const expect = std.testing.expect;

    const res = calculate("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))");
    try expect(res == 161);
}

test "example test2" {
    const expect = std.testing.expect;

    const res = calculate2("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))");
    try expect(res == 48);
}
