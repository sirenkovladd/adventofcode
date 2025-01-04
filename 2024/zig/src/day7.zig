const std = @import("std");
const file_contents = @embedFile("assert/day7.txt");

const Item = u50;
const ReturnType = Item;

fn valFromRow1(base: ReturnType, cur: Item, row: []Item) bool {
    if (cur > base) {
        return false;
    }
    if (row.len == 1) {
        // std.debug.print("{} {} {}\n", .{ base, cur, row[0] });
        return base == row[0] * cur or base == row[0] + cur;
    }
    if (valFromRow1(base, cur + row[0], row[1..])) {
        return true;
    }
    return valFromRow1(base, cur * row[0], row[1..]);
}

fn valFromRow2(base: ReturnType, cur: Item, row: []Item) bool {
    if (cur > base) {
        return false;
    }
    if (row.len == 0) {
        // std.debug.print("{} {} {}\n", .{ base, cur, row[0] });
        return base == cur;
    }
    if (valFromRow2(base, cur + row[0], row[1..])) {
        return true;
    }
    if (valFromRow2(base, cur * row[0], row[1..])) {
        return true;
    }
    var len: Item = 10;
    while (len <= row[0]) : (len *= 10) {}
    return valFromRow2(base, cur * len + row[0], row[1..]);
}

fn calculate(comptime validator: fn (ReturnType, Item, []Item) bool, inp: []const u8) ReturnType {
    var sum: ReturnType = 0;

    var page: [50]Item = undefined;
    var i: usize = 0;
    while (i < inp.len) : (i += 1) {
        const startB = i;
        i += 1;
        while (inp[i] != ':') {
            i += 1;
        }
        // std.debug.print("{s}\n", .{inp[startB..i]});
        const baseV = std.fmt.parseInt(ReturnType, inp[startB..i], 10) catch unreachable;

        i += 2;

        var n: u8 = 0;
        while (i < inp.len and inp[i] != '\n') {
            if (inp[i] == ' ') i += 1;
            const startV = i;
            i += 1;
            while (i < inp.len and '0' <= inp[i] and inp[i] <= '9') {
                i += 1;
            }
            const val = std.fmt.parseInt(Item, inp[startV..i], 10) catch unreachable;

            page[n] = val;
            n += 1;
        }
        if (validator(baseV, 0, page[0..n])) {
            // std.debug.print("valid {} {any}\n", .{ baseV, page[0..n] });
            sum += baseV;
        } else {
            // std.debug.print("invalid {} {any}\n", .{ baseV, page[0..n] });
        }
    }
    return sum;
}

pub fn result1() ReturnType {
    return calculate(valFromRow1, file_contents); // 663613490587
}

pub fn result2() ReturnType {
    return calculate(valFromRow2, file_contents); // 110365987435001
}

test "example test1" {
    const expect = std.testing.expectEqual;

    const exmpl1 =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;

    const res1 = calculate(valFromRow1, exmpl1);
    try expect(3749, res1);
    // std.debug.print("\n", .{});
    const res2 = calculate(valFromRow2, exmpl1);
    try expect(11387, res2);
}
