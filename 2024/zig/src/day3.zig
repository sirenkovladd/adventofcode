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

fn calculate(inp: []const u8) ResultType1 {
    var result: ResultType1 = 0;
    var i: usize = 0;
    var state: u4 = 0;
    const match = "mul(";
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

pub fn result1() ResultType1 {
    return calculate(file_contents);
}

test "example test1" {
    const expect = std.testing.expect;

    const res = calculate("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))");
    try expect(res == 161);
}
