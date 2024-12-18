const std = @import("std");
const file_contents = @embedFile("assert/day5.txt");

const ResultType1 = u16;
const Item = u8;
const MaxItem: Item = 100;
const Page = []const Item;
const Rule = [2]Item;
const MaxIdx = @as(usize, MaxItem) * (MaxItem - 1);

inline fn getIndex(v1: Item, v2: Item) usize {
    return @as(usize, 1) * v1 * MaxItem + v2;
}

fn calculate1(inp: []const u8) ResultType1 {
    // use MaxIdx BYTES not BITS, but faster
    var rule: [MaxIdx]bool = undefined;
    @memset(rule[0..MaxIdx], false);
    var i: usize = 0;
    while (inp[i] != '\n') : (i += 1) {
        const startV1 = i;
        while (inp[i] != '|') {
            i += 1;
        }
        const v1 = std.fmt.parseInt(Item, inp[startV1..i], 10) catch unreachable;
        i += 1;
        const startV2 = i;
        while (inp[i] != '\n') {
            i += 1;
        }
        const v2 = std.fmt.parseInt(Item, inp[startV2..i], 10) catch unreachable;

        const idx = getIndex(v2, v1);
        rule[idx] = true;
    }

    i += 1;

    var sum: ResultType1 = 0;

    var pageList: [MaxItem]Item = undefined;
    nextPage: while (i < inp.len) : (i += 1) {
        var n2: Item = 0;
        while (i < inp.len and inp[i] != '\n') {
            if (inp[i] == ',') {
                i += 1;
            }
            const startI = i;

            while (i < inp.len and '0' - 1 < inp[i] and inp[i] < '9' + 1) {
                i += 1;
            }
            const v = std.fmt.parseInt(Item, inp[startI..i], 10) catch unreachable;
            for (pageList[0..n2]) |v2| {
                const idx = getIndex(v2, v);
                if (rule[idx]) {
                    while (i < inp.len and inp[i] != '\n') {
                        i += 1;
                    }
                    continue :nextPage;
                }
            }
            pageList[n2] = v;
            n2 += 1;
        }
        const res = pageList[n2 / 2];
        sum += res;
    }
    return sum;
}

pub fn result1() ResultType1 {
    return calculate1(file_contents);
}

test "example test1" {
    const expect = std.testing.expect;

    const exmpl1 =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    const res1 = calculate1(exmpl1);
    try expect(res1 == 143);

    const exmpl2 = @embedFile("assert/day5.txt");
    const res2 = calculate1(exmpl2);
    try expect(res2 == 4959);
}
