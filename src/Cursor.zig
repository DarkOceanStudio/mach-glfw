//! Represents a cursor and provides facilities for setting cursor images.

const std = @import("std");
const testing = std.testing;

const c = @import("c.zig").c;
const Error = @import("errors.zig").Error;
const getError = @import("errors.zig").getError;
const Image = @import("Image.zig");

const Cursor = @This();

ptr: *c.GLFWcursor,

/// Creates a custom cursor.
///
/// Creates a new custom cursor image that can be set for a window with glfw.Cursor.set. The cursor
/// can be destroyed with glfwCursor.destroy. Any remaining cursors are destroyed by glfw.terminate.
///
/// The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight bits per channel with
/// the red channel first. They are arranged canonically as packed sequential rows, starting from
/// the top-left corner.
///
/// The cursor hotspot is specified in pixels, relative to the upper-left corner of the cursor
/// image. Like all other coordinate systems in GLFW, the X-axis points to the right and the Y-axis
/// points down.
///
/// @param[in] image The desired cursor image.
/// @param[in] xhot The desired x-coordinate, in pixels, of the cursor hotspot.
/// @param[in] yhot The desired y-coordinate, in pixels, of the cursor hotspot.
/// @return The handle of the created cursor.
///
/// Possible errors include glfw.Error.NotInitialized and glfw.Error.PlatformError.
///
/// @pointer_lifetime The specified image data is copied before this function returns.
///
/// @thread_safety This function must only be called from the main thread.
///
/// see also: cursor_object, glfw.Cursor.destroy, glfw.Cursor.createStandard
pub inline fn create(image: Image, xhot: isize, yhot: isize) Error!Cursor {
    const img = image.toC();
    const cursor = c.glfwCreateCursor(&img, @intCast(c_int, xhot), @intCast(c_int, yhot));
    try getError();
    return Cursor{ .ptr = cursor.? };
}

// TODO(cursor icon)
// /// Creates a cursor with a standard shape.
// ///
// /// Returns a cursor with a [standard shape](@ref shapes), that can be set for
// /// a window with @ref glfwSetCursor.
// ///
// /// @param[in] shape One of the [standard shapes](@ref shapes).
// /// @return A new cursor ready to use or null if an
// /// error occurred.
// ///
// /// Possible errors include glfw.Error.NotInitialized, glfw.Error.InvalidEnum and glfw.Error.PlatformError.
// ///
// /// @thread_safety This function must only be called from the main thread.
// ///
// /// see also: cursor_object, glfwCreateCursor
// ///
// ///
// /// @ingroup input
// GLFWAPI GLFWcursor* glfwCreateStandardCursor(int shape);

// TODO(cursor icon)
// /// Destroys a cursor.
// ///
// /// This function destroys a cursor previously created with @ref
// /// glfwCreateCursor. Any remaining cursors will be destroyed by @ref
// /// glfwTerminate.
// ///
// /// If the specified cursor is current for any window, that window will be
// /// reverted to the default cursor. This does not affect the cursor mode.
// ///
// /// @param[in] cursor The cursor object to destroy.
// ///
// /// Possible errors include glfw.Error.NotInitialized and glfw.Error.PlatformError.
// ///
// /// @reentrancy This function must not be called from a callback.
// ///
// /// @thread_safety This function must only be called from the main thread.
// ///
// /// see also: cursor_object, glfwCreateCursor
// ///
// ///
// /// @ingroup input
// GLFWAPI void glfwDestroyCursor(GLFWcursor* cursor);

test "create" {
    const allocator = testing.allocator;

    const glfw = @import("main.zig");
    try glfw.init();
    defer glfw.terminate();

    const image = try Image.init(allocator, 32, 32, 32 * 32 * 4);
    defer image.deinit(allocator);

    _ = glfw.Cursor.create(image, 0, 0) catch |err| std.debug.print("failed to create cursor, custom cursors not supported? error={}\n", .{err});
}