const std = @import("std");
const log = std.log.scoped(.main);
const pr = std.io.getStdOut().writer();

fn countNeighbors(board: [][]u8, x: usize, y: usize, height: usize, width: usize) usize {
    // Check bounds
    std.debug.assert(x >= 0);
    std.debug.assert(y >= 0);
    std.debug.assert(x < height);
    std.debug.assert(y < width);

    // Get the nearest neighbors
    const neighbors = collectNeighbors(board, x, y);

    // Count the number of living neighbors
    var count: usize = 0;
    for (neighbors) |i| count += i;

    // Return the count
    return count;
}

fn collectNeighbors(board: [][]u8, x: usize, y: usize) [8]u8 {
    var neighborList: [8]u8 = .{0} ** 8;

    const steps = [8][2]isize{ .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 }, .{ -1, 0 }, .{ 1, 0 }, .{ -1, 1 }, .{ 0, 1 }, .{ 1, 1 } };

    for (steps, 0..) |step, i| {
        const int_step_x = @as(usize, @abs(step[0]));
        const int_step_y = @as(usize, @abs(step[1]));
        const x_pos = if (step[0] > 0) x + int_step_x else x -% int_step_x;
        const y_pos = if (step[1] > 0) y + int_step_y else y -% int_step_y;

        neighborList[i] = safeAccess(board, x_pos, y_pos);
    }

    return neighborList;
}

fn safeAccess(board: []const []const u8, x: usize, y: usize) u8 {
    if (x < board.len and y < board[0].len) {
        // std.debug.print("Accessing: {d}, {d}\n", .{ x, y });
        return board[x][y];
    } else {
        return 0;
    }
}

fn boardPrint(board: [][]u8, allocator: std.mem.Allocator) ![]u8 {
    // Create a buffer to store the printed board
    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();

    // try buf.append('\r');

    // Print the board to the buffer
    for (board) |row| {
        for (row) |cell| {
            try buf.append(if (cell == 1) '#' else '.');
        }
        // try buf.append('\r');
        try buf.append('\n');
    }

    // Return the buffer as a slice
    return buf.toOwnedSlice();
}

fn allocateBoard(comptime T: type, allocator: std.mem.Allocator, cols: usize, rows: usize, defaultVal: T) ![][]T {
    // Allocate the board
    const board = try allocator.alloc([]T, rows);
    errdefer freeBoard(board, allocator);

    for (board) |*row| {
        // Allocate the rows
        row.* = try allocator.alloc(T, cols);

        errdefer allocator.free(row.*);
        // Set the default value
        @memset(row.*, defaultVal);
    }

    // Return the board
    return board;
}

fn freeBoard(board: anytype, allocator: std.mem.Allocator) void {
    // Free the board
    for (board) |row| {
        allocator.free(row);
    }
    allocator.free(board);
}

fn processCommandLineArgs(args: *std.process.ArgIterator, width: *usize, height: *usize, setList: *std.ArrayList([2]u8)) !void {
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--help")) {
            try pr.print("Usage: cgol [options]\n", .{});
            try pr.print("Options:\n", .{});
            try pr.print("  help: Display this help message\n", .{});
            try pr.print("  version: Display the version\n", .{});
            try pr.print("  width: Set the width of the board\n", .{});
            try pr.print("  height: Set the height of the board\n", .{});
            try pr.print("  set: Set the initial state of the board, end with ;\n", .{});
        } else if (std.mem.eql(u8, arg, "--version")) {
            try pr.print("Conway's Game of Life v0.1.0\n", .{});
        } else if (std.mem.eql(u8, arg, "--width")) {
            width.* = try std.fmt.parseInt(usize, args.next().?, 10);
            try pr.print("Width: {d}\n", .{width.*});
        } else if (std.mem.eql(u8, arg, "--height")) {
            height.* = try std.fmt.parseInt(usize, args.next().?, 10);
            try pr.print("Height: {d}\n", .{height.*});
        } else if (std.mem.eql(u8, arg, "--set")) {
            while (args.next()) |arg_mini| {
                if (std.mem.eql(u8, arg_mini, "%")) {
                    break;
                } else if (std.mem.eql(u8, arg_mini, " ") or std.mem.eql(u8, arg_mini, ",")) {
                    continue;
                }

                const x = try std.fmt.charToDigit(arg_mini[0], 10);
                const y = try std.fmt.charToDigit(arg_mini[2], 10);

                if (@as(usize, x) > width.* or @as(usize, y) > height.*) {
                    try pr.print("Set point out of bounds (over)\n", .{});
                } else if (x < 0 or y < 0) {
                    try pr.print("Set point out of bounds (under)\n", .{});
                }

                try setList.append(.{ x, y });
            }
            try pr.print("Preset points: {any}\n", .{setList.items});
        } else {
            try pr.print("Unknown option: {s}\n", .{arg});
            break;
        }
    }
}

fn copyBoard(oldBoard: [][]u8, board: [][]u8) void {
    for (oldBoard, 0..) |row, i| {
        std.mem.copyForwards(u8, board[i], row);
    }
}

pub fn main() !void {
    // Set up allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            log.err("memory leak", .{});
        }
    }
    const alloc = gpa.allocator();

    // Get command line args
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    _ = args.skip(); // Skip the program name

    // Instantiate width and height defaults
    var width: usize = 10;
    var height: usize = 10;

    // Instantiate preset point list
    var setList = std.ArrayList([2]u8).init(alloc);
    defer setList.deinit();

    // Process command line args
    try processCommandLineArgs(&args, &width, &height, &setList);

    // Allocate board
    var board = try allocateBoard(u8, alloc, width, height, 0);
    defer freeBoard(board, alloc);

    // Set preset points
    for (setList.items) |set| {
        board[set[0]][set[1]] = 1;
    }

    // Main loop
    while (true) : (std.time.sleep(3000)) {
        // Print the board to stdout
        const printed_board = try boardPrint(board, alloc);
        defer alloc.free(printed_board);

        try pr.print("\r{s}", .{printed_board});

        // Set up a buffer board for upcoming changes
        var newBoard = try allocateBoard(u8, alloc, height, width, 0);
        defer freeBoard(newBoard, alloc);

        // Iterate over the rows
        for (board, 0..) |row, row_idx| {
            // Iterate over the cells
            for (row, 0..) |_, cell_idx| {
                // Get the number of living neighbors
                const neighborCount = countNeighbors(board, row_idx, cell_idx, height, width);

                // Apply the rules of the game
                switch (neighborCount) {
                    2 => {
                        if (board[row_idx][cell_idx] == 1) {
                            newBoard[row_idx][cell_idx] = 1;
                        }
                    },
                    3 => {
                        if (board[row_idx][cell_idx] == 0) {
                            newBoard[row_idx][cell_idx] = 1;
                        }
                    },
                    else => newBoard[row_idx][cell_idx] = 0,
                }
            }
        }

        // Update the board
        copyBoard(newBoard, board);
    }
}

test "collectNeighbors normal case" {
    const board = try allocateBoard(u8, std.testing.allocator, 10, 10, 0);
    defer freeBoard(board, std.testing.allocator);

    board[2][2] = 1;
    board[2][4] = 1;
    board[4][2] = 1;
    board[4][4] = 1;

    const expected: [8]u8 = .{ 1, 0, 1, 0, 0, 1, 0, 1 };
    const neighbors: [8]u8 = collectNeighbors(board, 3, 3);
    try std.testing.expectEqual(expected, neighbors);

    const buf = try boardPrint(board, std.testing.allocator);
    defer std.testing.allocator.free(buf);
    try pr.print("{s}\n", .{buf});
}

test "collectNeighbors OOB case" {
    const board = try allocateBoard(u8, std.testing.allocator, 10, 10, 0);
    defer freeBoard(board, std.testing.allocator);

    board[0][1] = 1;
    board[1][0] = 1;
    board[1][1] = 1;

    const expected: [8]u8 = .{ 0, 0, 0, 0, 1, 0, 1, 1 };
    const neighbors: [8]u8 = collectNeighbors(board, 0, 0);
    try std.testing.expectEqual(expected, neighbors);
}

test "allocateBoard" {
    const board = try allocateBoard(u8, std.testing.allocator, 10, 10, 0);
    defer freeBoard(board, std.testing.allocator);

    try std.testing.expect(board.len == 10);
    try std.testing.expect(board[0].len == 10);
}

test "countNeighbors normal case" {
    const board = try allocateBoard(u8, std.testing.allocator, 10, 10, 0);
    defer freeBoard(board, std.testing.allocator);

    board[2][2] = 1;
    board[2][4] = 1;
    board[4][2] = 1;
    board[4][4] = 1;

    const count = countNeighbors(board, 3, 3, 10, 10);
    try pr.print("Count: {d}\n", .{count});
    try std.testing.expect(count == 4);
}
