const std = @import("std");
const file_contents = @embedFile("assert/day9.txt");

const ReturnType = u44;
const ID = u16;
const Val = u8;

const Summator = struct {
    const Self = @This();
    result: ReturnType = 0,
    pos: ReturnType = 0,
    fn add(self: *Self, val: ID) void {
        // std.debug.print("val: {} pos: {}\n", .{ val, self.pos });
        const mul = @mulWithOverflow(val, self.pos);
        if (mul[1] == 1) @panic("overflow");
        const sum = @addWithOverflow(self.result, mul[0]);
        // std.debug.print("mul: {} sum: {} overflow: {} type_sum: {} type_mul: {}\n", .{ mul[0], sum[0], sum[1], @TypeOf(sum[0]), @TypeOf(mul[0]) });
        if (sum[1] == 1) @panic("overflow");
        self.result = sum[0];
        self.pos += 1;
    }
};

const Reader = struct {
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

fn calculate(inp: []const u8) ReturnType {
    var summator = Summator{};
    var reader = Reader.init(inp);
    while (reader.next()) |val| {
        summator.add(val);
    }
    return summator.result;
}

pub fn result1() ReturnType {
    return calculate(file_contents); // 6331212425418
}

// pub fn result2() ReturnType {
//     return calculate(file_contents); // ?
// }

test "example test1" {
    const expect = std.testing.expectEqual;

    const exmpl = "12345";

    const res1 = calculate(exmpl);
    try expect(60, res1);
}

test "example test2" {
    const expect = std.testing.expectEqual;

    const exmpl = "2333133121414131402";

    const res1 = calculate(exmpl);
    try expect(1928, res1);
}
