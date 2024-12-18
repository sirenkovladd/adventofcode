const std = @import("std");
const file_contents = @embedFile("assert/day4.txt");

const ResultType1 = u16;

fn nXmas(inp: []const u8, row_len: usize, i: usize) ResultType1 {
    const x = i % (row_len + 1);
    const y = i / (row_len + 1);
    const height = inp.len / row_len;
    var res: ResultType1 = 0;
    if (x + 3 < row_len) {
        // ->
        if (std.mem.eql(u8, inp[i + 1 .. i + 4], "MAS")) {
            res += 1;
        }
        // South East ↘
        if (y + 3 < height) {
            if (inp[i + row_len + 2] == 'M' and inp[i + 2 * row_len + 4] == 'A' and inp[i + 3 * row_len + 6] == 'S') {
                res += 1;
            }
        }
        // North East ↗
        if (y >= 3) {
            if (inp[i - row_len] == 'M' and inp[i - 2 * row_len] == 'A' and inp[i - 3 * row_len] == 'S') {
                res += 1;
            }
        }
    }
    if (x >= 3) {
        // <-
        if (std.mem.eql(u8, inp[i - 3 .. i], "SAM")) {
            res += 1;
        }
        // North West ↖
        if (y >= 3) {
            if (inp[i - row_len - 2] == 'M' and inp[i - 2 * row_len - 4] == 'A' and inp[i - 3 * row_len - 6] == 'S') {
                res += 1;
            }
        }
        // South West ↙
        if (y + 3 < height) {
            if (inp[i + row_len] == 'M' and inp[i + 2 * row_len] == 'A' and inp[i + 3 * row_len] == 'S') {
                res += 1;
            }
        }
    }
    if (y >= 3) {
        // ↑
        if (inp[i - row_len - 1] == 'M' and inp[i - 2 * row_len - 2] == 'A' and inp[i - 3 * row_len - 3] == 'S') {
            res += 1;
        }
    }
    if (y + 3 < height) {
        // ↓
        if (inp[i + row_len + 1] == 'M' and inp[i + 2 * row_len + 2] == 'A' and inp[i + 3 * row_len + 3] == 'S') {
            res += 1;
        }
    }
    // std.debug.print("{} {} {} {} -> {} \n", .{ x, y, row_len, height, res });
    return res;
}

fn validDiagonal(v1: u8, v2: u8) bool {
    return (v1 == 'M' or v1 == 'S') and (v2 == 'M' or v2 == 'S') and v1 != v2;
}

fn nX_mas(inp: []const u8, row_len: usize, i: usize) bool {
    const x = i % (row_len + 1);
    const y = i / (row_len + 1);
    const height = inp.len / row_len;
    return 0 < x and x + 1 < row_len and 0 < y and y + 1 < height and validDiagonal(inp[i - row_len - 2], inp[i + row_len + 2]) and validDiagonal(inp[i - row_len], inp[i + row_len]);
}

fn calculate1(inp: []const u8) ResultType1 {
    const row_len = end: {
        for (0..inp.len) |i| {
            if (inp[i] == '\n') break :end i;
        }
        unreachable;
    };
    // std.debug.print("{}\n", .{row_len});
    var sum: ResultType1 = 0;
    for (0..inp.len, inp) |i, c| {
        if (c == 'X') {
            sum += nXmas(inp, row_len, i);
        }
    }
    return sum;
}

pub fn result1() ResultType1 {
    return calculate1(file_contents); // 2718
}

fn calculate2(inp: []const u8) ResultType1 {
    const row_len = end: {
        for (0..inp.len) |i| {
            if (inp[i] == '\n') break :end i;
        }
        unreachable;
    };
    // std.debug.print("{}\n", .{row_len});
    var sum: ResultType1 = 0;
    for (0..inp.len, inp) |i, c| {
        if (c == 'A' and nX_mas(inp, row_len, i)) {
            sum += 1;
        }
    }
    return sum;
}

pub fn result2() ResultType1 {
    return calculate2(file_contents); // 2046
}

test "example test1" {
    const expect = std.testing.expect;

    const exmpl =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const res1 = calculate1(exmpl);
    const res2 = calculate2(exmpl);
    try expect(res1 == 18);
    try expect(res2 == 9);
}

test "example test2" {
    const expect = std.testing.expect;

    const res = calculate1(
        \\XMAS
        \\.MAM
        \\.MA.
        \\XS.S
    );
    try expect(res == 3);
}
