const std = @import("std");
const clap = @import("clap");

const debug = std.debug;
const io = std.io;
const mem = std.mem;
const meta = std.meta;

const Commands = enum { add, remove, list, connect };

pub fn main() !void {
    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h, --help             Display this help and exit.              ") catch unreachable,
        clap.parseParam("<POS>...") catch unreachable,
    };

    var args = clap.parse(clap.Help, &params, .{}) catch |err| {
        return err;
    };

    defer args.deinit();

    if (args.flag("--help")) {
        printHelp(&params);
    }

    for (args.positionals()) |pos| {
        const command_enum: ?Commands = meta.stringToEnum(Commands, pos);
        if (command_enum) |command| {
            switch (command) {
                .add => {
                    addConnectionString();
                },
                .remove => {
                    removeConnectionString();
                },
                .list => {
                    listConnectionStrings();
                },
                .connect => {
                    execConnection();
                },
            }
        } else {
            debug.print("Invalid command, please use -h", .{});
        }
    }
}

fn printHelp(params: []const clap.Param(clap.Help)) void {
    const std_error_writer = std.io.getStdErr().writer();
    write(std_error_writer, "Usage: sshman [add|remove|list|connect] \n");
    clap.help(std_error_writer, params) catch {};
    write(std_error_writer, comptime bold("Sub Commands"));
    write(std_error_writer, " add     -  Add a connection string to the manager (eg: add \"root@example.com -i cert.pem\" \"Example\")");
    write(std_error_writer, " remove  -  remove a connection string to the manager (eg: remove 12)");
    write(std_error_writer, " list    -  list stored connection strings");
    write(std_error_writer, " connect -  try an ssh connection on the selected string (eg: connect 12)");
}

// write | simple error digesting write stream printer
fn write(stream: anytype, comptime message: []const u8) void {
    stream.print("\n" ++ message, .{}) catch {};
}

// bold | bold terminal font with reset
fn bold(comptime str: []const u8) []const u8 {
    return "\x1b[1m" ++ str ++ "\x1b[0m";
}

// TODO:
// - [ ] add in a small file db using known_locations to handle global access to data
// - [ ] each listing to have a pre-constructed ssh string and an
//   id and the raw string provided by the user
// - [ ] removal will use the id of the above to get rid of it
// - [ ] connect will use the preconstructed string to start a tty to connect
// - [ ] find a good way to launch the default tty helper or if adding a global config
//   allows users to add in the launch command for it

fn addConnectionString() void {}

fn removeConnectionString() void {}

fn listConnectionStrings() void {}

fn execConnection() void {}
