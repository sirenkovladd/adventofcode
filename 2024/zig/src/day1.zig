const std = @import("std");

fn parseRow(input: []const u8, i: *usize, minTypeInt: type) !struct { minTypeInt, minTypeInt } {
    const start = i.*;
    while (input[i.*] != ' ') {
        i.* += 1;
    }
    const v1 = try std.fmt.parseInt(minTypeInt, input[start..i.*], 10);

    while (input[i.*] == ' ') {
        i.* += 1;
    }

    const start2 = i.*;
    while (i.* < input.len and input[i.*] != '\n') {
        i.* += 1;
    }

    const v2 = try std.fmt.parseInt(minTypeInt, input[start2..i.*], 10);
    i.* += 1;
    return .{ v1, v2 };
}

fn calculate(input: []const u8, minTypeInt: type, allocator: std.mem.Allocator) !u32 {
    var first = std.ArrayList(minTypeInt).init(allocator);
    defer first.deinit();
    var second = std.ArrayList(minTypeInt).init(allocator);
    defer second.deinit();
    var i: usize = 0;
    while (i < input.len) {
        const row = try parseRow(input, &i, minTypeInt);
        try first.append(row[0]);
        try second.append(row[1]);
    }

    const lessThan = struct {
        fn lessThen(context: void, v1: minTypeInt, v2: minTypeInt) bool {
            _ = context;
            return v1 < v2;
        }
    }.lessThen;

    std.sort.block(minTypeInt, first.items, {}, lessThan);
    std.sort.block(minTypeInt, second.items, {}, lessThan);

    var sum: u32 = 0;
    for (first.items, second.items) |v1, v2| {
        sum += @abs(@as(i18, v1) - @as(i18, v2));
    }
    return sum;
}

pub fn result(allocator: std.mem.Allocator) !u32 {
    const file_contents = @embedFile("day1");
    return calculate(file_contents, u17, allocator);
}

test "simple test" {
    const expect = std.testing.expect;

    const res = try calculate("123 123", u8, std.testing.allocator);
    try expect(res == 0);
}

test "example test" {
    const expect = std.testing.expect;

    const res = try calculate("3 4\n4 3\n2 5\n1 3\n3 9\n3 3", u4, std.testing.allocator);
    try expect(res == 11);
}
