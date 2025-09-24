const std = @import("std");
const expect = std.testing.expectEqual;
const file_contents = @embedFile("assert/day9.txt");

const ReturnType = u44;
const ID = u16;
const Val = u8;

const Block = struct {
    id: ID,
    val: Val,
};

const En = union(enum) {
    skip: Val,
    block: Block,
};

const Summator = struct {
    const Self = @This();
    result: ReturnType = 0,
    pos: ReturnType = 0,
    fn add(self: *Self, val: ID) void {
        // std.debug.print("val: {} pos: {}\n", .{ val, self.pos });
        const mul = @mulWithOverflow(val, self.pos);
        std.debug.assert(mul[1] == 0);
        const sum = @addWithOverflow(self.result, mul[0]);
        // std.debug.print("mul: {} sum: {} overflow: {} type_sum: {} type_mul: {}\n", .{ mul[0], sum[0], sum[1], @TypeOf(sum[0]), @TypeOf(mul[0]) });
        std.debug.assert(sum[1] == 0);
        self.result = sum[0];
        self.pos += 1;
    }
    fn inc(self: *Self, n: ID) void {
        self.pos += n;
    }
};

const Reader1 = struct {
    const Self = @This();
    inp: []const u8,
    pos: usize = 0,
    posR: usize,
    curID: ID = 0,
    left: Val,
    curID_R: ID,
    left_R: Val,
    isEmpty: bool = false,
    fn init(inp: []const u8) Self {
        return .{
            .inp = inp,
            .posR = inp.len - 1,
            .left = inp[0] - '0',
            .curID_R = @as(u16, @intCast(inp.len)) >> 1,
            .left_R = inp[inp.len - 1] - '0',
        };
    }
    fn next(self: *Self) ?ID {
        // std.debug.print("pos: {} left: {} posR: {} leftR: {} curID: {} curID_R: {}\n", .{ self.pos, self.left, self.posR, self.left_R, self.curID, self.curID_R });
        if (self.isEmpty) {
            if (self.left == 0) {
                self.pos += 1;
                self.left = self.inp[self.pos] - '0';
                self.isEmpty = false;
                self.curID += 1;
                return self.next();
            }
            if (self.left_R == 0) {
                self.curID_R -= 1;
                if (self.curID == self.curID_R) {
                    return null;
                }
                self.posR -= 2;
                self.left_R = self.inp[self.posR] - '0';
            }
            self.left -= 1;
            self.left_R -= 1;
            return self.curID_R;
        }
        if (self.curID == self.curID_R) {
            if (self.left_R == 0) return null;
            self.left_R -= 1;
            return self.curID;
        }
        if (self.left == 0) {
            self.pos += 1;
            self.left = self.inp[self.pos] - '0';
            self.isEmpty = true;
            return self.next();
        }
        self.left -= 1;
        return self.curID;
    }
};

const Reader2 = struct {
    const Self = @This();
    list: []En,
    fn init(list: []En) Self {
        return .{
            .list = list,
        };
    }
    fn next(self: *Self) ?En {
        // std.debug.print("pos: {} left: {} posR: {} leftR: {} curID: {} curID_R: {}\n", .{ self.pos, self.left, self.posR, self.left_R, self.curID, self.curID_R });
        const len = self.list.len;
        if (len == 0) {
            return null;
        }
        std.debug.print("len: {} {}\n", .{ len, self.list[0] });
        switch (self.list[0]) {
            .skip => |*n| {
                if (n.* == 0) {
                    self.list = self.list[1..];
                    return self.next();
                }
                for (1..len - 1) |diff| {
                    const i = len - diff;
                    switch (self.list[i]) {
                        .skip => |_| {
                            continue;
                        },
                        .block => |block| {
                            if (block.val <= n.*) {
                                n.* -= block.val;
                                if (i + 2 < len) {
                                    const l = &self.list[i - 1];
                                    const r = self.list[i + 1];
                                    l.skip += r.skip + 1;
                                    std.mem.copyForwards(En, self.list[i..], self.list[i + 2 ..]);
                                    self.list = self.list[0 .. len - 2];
                                    return En{ .block = .{ .id = block.id, .val = block.val } };
                                }
                                self.list = self.list[0 .. len - 1];
                                return En{ .block = .{ .id = block.id, .val = block.val } };
                            }
                        },
                    }
                }
                self.list = self.list[1..];
                return En{ .skip = n.* };
            },
            .block => |block| {
                if (block.val == 0) {
                    self.list = self.list[1..];
                    return self.next();
                }
                self.list = self.list[1..];
                return En{ .block = .{ .id = block.id, .val = block.val } };
            },
        }
    }
};

fn calculate1(inp: []const u8) ReturnType {
    var summator = Summator{};
    var reader = Reader1.init(inp);
    while (reader.next()) |val| {
        summator.add(val);
    }
    return summator.result;
}

fn calculate2(inp: []const u8) ReturnType {
    const SIZE = 2000;
    std.debug.assert((inp.len) <= SIZE);
    var ids: [SIZE]En = undefined;
    for (inp, 0..) |n, i| {
        if (i & 1 == 0) {
            ids[i] = En{ .block = .{ .id = @intCast(i >> 1), .val = n - '0' } };
        } else {
            ids[i] = En{ .skip = n - '0' };
        }
    }
    var reader = Reader2.init(ids[0..inp.len]);
    var summator = Summator{};
    while (reader.next()) |val| {
        std.debug.print("result: {}\n", .{val});
        switch (val) {
            .skip => |n| {
                summator.inc(n);
            },
            .block => |block| {
                for (0..block.val) |_| {
                    summator.add(block.id);
                }
            },
        }
    }
    return summator.result;
}

pub fn result1() ReturnType {
    return calculate1(file_contents); // 6331212425418
}

pub fn result2() ReturnType {
    return calculate2(file_contents); // ?
}

// test "example test1" {
//     const exmpl = "12345";

//     const res1 = calculate1(exmpl);
//     try expect(60, res1);
// }

test "example test2" {
    const exmpl = "2333133121414131402";

    // const res1 = calculate1(exmpl);
    // try expect(1928, res1);

    // var exmpl1 = exmpl.*;
    const res2 = calculate2(exmpl);
    try expect(2858, res2);
}
