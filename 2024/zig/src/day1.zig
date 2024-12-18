const std = @import("std");
const file_contents = @embedFile("assert/day1.txt");

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

fn parse(input: []const u8, comptime minTypeInt: type, allocator: std.mem.Allocator) !struct { std.ArrayList(minTypeInt), std.ArrayList(minTypeInt) } {
    var first = try std.ArrayList(minTypeInt).initCapacity(allocator, 1024);
    var second = try std.ArrayList(minTypeInt).initCapacity(allocator, 1024);
    var i: usize = 0;
    while (i < input.len) {
        const row = try parseRow(input, &i, minTypeInt);
        try first.append(row[0]);
        try second.append(row[1]);
    }
    return .{ first, second };
}

fn calculate(input: []const u8, comptime minTypeInt: type, allocator: std.mem.Allocator) !u32 {
    const parsed = try parse(input, minTypeInt, allocator);
    const first = parsed[0];
    const second = parsed[1];
    defer first.deinit();
    defer second.deinit();
    const lessThan = struct {
        fn lessThen(context: void, v1: minTypeInt, v2: minTypeInt) bool {
            _ = context;
            return v1 < v2;
        }
    }.lessThen;

    std.sort.block(minTypeInt, first.items, {}, lessThan);
    std.sort.block(minTypeInt, second.items, {}, lessThan);

    const signedType = std.meta.Int(.signed, @typeInfo(minTypeInt).Int.bits + 1);

    var sum: u32 = 0;
    for (first.items, second.items) |v1, v2| {
        sum += @abs(@as(signedType, v1) - @as(signedType, v2));
    }
    return sum;
}

fn calculate2(input: []const u8, comptime minTypeInt: type, allocator: std.mem.Allocator) !u32 {
    const parsed = try parse(input, minTypeInt, allocator);
    const first = parsed[0];
    const second = parsed[1];
    defer first.deinit();
    defer second.deinit();

    var map = std.AutoHashMap(minTypeInt, u8).init(allocator);
    try map.ensureTotalCapacity(1 << 9);
    defer map.deinit();
    for (second.items) |val| {
        const entr = try map.getOrPut(val);
        if (!entr.found_existing) {
            entr.value_ptr.* = 0;
        }
        entr.value_ptr.* += 1;
    }

    var sum: u32 = 0;
    for (first.items) |val| {
        sum += val * @as(u32, @intCast((map.get(val) orelse 0)));
    }
    return sum;
}

pub fn result(allocator: std.mem.Allocator) !u32 {
    return calculate(file_contents, u17, allocator); // 2113135
}

pub fn result2(allocator: std.mem.Allocator) !u32 {
    return calculate2(file_contents, u17, allocator); // 19097157
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

test "part 2 test" {
    const expect = std.testing.expect;

    const res = try calculate2("3 4\n4 3\n2 5\n1 3\n3 9\n3 3", u4, std.testing.allocator);
    try expect(res == 31);
}
