defmodule ExTermbox.Bindings do
  @moduledoc """
  Provides the low-level bindings to the termbox library. This module loads the
  NIFs defined in `c_src/` and thinly wraps the C interface.

  Note that rather than calling the termbox bindings directly, it's preferred
  to use the higher-level constructs (e.g., `ExTermbox.Window`,
  `ExTermbox.EventManager`, `ExTermbox.Renderer`) where possible, as these
  manage things like initialization and shutdown automatically, as well as
  provide a functional, declarative interface for rendering content to the screen.

  See also the termbox header file for additional documentation of the functions
  here:

  <https://github.com/nsf/termbox/blob/master/src/termbox.h>
  """

  alias ExTermbox.{Cell, Position}

  @on_load :load_nifs

  def load_nifs do
    so_path = Path.join(:code.priv_dir(:ex_termbox), "termbox_bindings")
    :erlang.load_nif(so_path, 0)
  end

  @doc """
  Initializes the termbox library. Must be called before any other bindings are
  called.

  Returns `:ok` on success. On error, returns a tuple `{:error, code}`
  containing an integer representing a termbox error code.
  """
  def init do
    raise("NIF init/0 not implemented")
  end

  @doc """
  Finalizes the termbox library. Should be called when the terminal application
  is exited, and before your program or OTP application stops.

  Returns `:ok`.
  """
  def shutdown do
    raise("NIF shutdown/0 not implemented")
  end

  @doc """
  Returns the width of the terminal window in characters. Undefined before
  `init/0` is called.
  """
  def width do
    raise("NIF width/0 not implemented")
  end

  @doc """
  Returns the height of the terminal window in characters. Undefined before
  `init/0` is called.
  """
  def height do
    raise("NIF height/0 not implemented")
  end

  @doc """
  Clears the internal back buffer, setting the foreground and background to
  the defaults, or those specified by `set_clear_attributes/2`.

  Returns `:ok`.
  """
  def clear do
    raise("NIF clear/0 not implemented")
  end

  @doc """
  Sets the default foreground and background colors used when `clear/0` is
  called.

  Returns `:ok`.
  """
  def set_clear_attributes(_fg, _bg) do
    raise("NIF set_clear_attributes/2 not implemented")
  end

  @doc """
  Synchronizes the internal back buffer and the terminal.

  Returns `:ok`.
  """
  def present do
    raise("NIF present/0 not implemented")
  end

  @doc """
  Sets the position of the cursor to the coordinates `(x, y)`, or hide the cursor
  by passing `ExTermbox.Constants.hide_cursor/0` for both x and y.

  Returns `:ok`.
  """
  def set_cursor(_x, _y) do
    raise("NIF set_cursor/2 not implemented")
  end

  @doc """
  Puts a cell in the internal back buffer at the cell's position. Note that this is
  implemented in terms of `change_cell/5`.

  Returns `:ok`.
  """
  def put_cell(%Cell{position: %Position{x: x, y: y}, char: ch, fg: fg, bg: bg}) do
    change_cell(x, y, ch, fg, bg)
  end

  @doc """
  Changes the attributes of the cell at the specified position in the internal
  back buffer. Prefer using `put_cell/1`, which supports passing an
  `ExTermbox.Cell` struct.

  Returns `:ok`.
  """
  def change_cell(_x, _y, _ch, _fg, _bg) do
    raise("NIF change_cell/5 not implemented")
  end

  @doc """
  Sets or retrieves the input mode (see `ExTermbox.Constants.input_modes/0`).
  See the [termbox source](https://github.com/nsf/termbox/blob/master/src/termbox.h)
  for additional documentation.

  Returns an integer representing the input mode.
  """
  def select_input_mode(_mode) do
    raise("NIF select_input_mode/1 not implemented")
  end

  @doc """
  Sets or retrieves the output mode (see `ExTermbox.Constants.output_modes/0`).
  See the [termbox source](https://github.com/nsf/termbox/blob/master/src/termbox.h)
  for additional documentation.

  Returns an integer representing the output mode.
  """
  def select_output_mode(_mode) do
    raise("NIF select_output_mode/1 not implemented")
  end

  @doc """
  Polls for a terminal event asynchronously. The function accepts a PID as
  argument and returns immediately. When an event is received, it's sent to the
  specified process. To receive additional events, it's necessary to call this
  function again.

  In the underlying NIF, a thread is created which performs the blocking event
  poll. This allows the NIF to return quickly and avoid causing trouble for the
  scheduler.

  Note that the `ExTermbox.EventManager` is an abstraction over this function
  that listens continuously for events and supports multiple subscriptions.

  Returns a resource representing a handle for the poll thread.
  """
  def poll_event(pid) when is_pid(pid) do
    raise("NIF poll_event/1 not implemented")
  end

  @doc """
  *Not yet implemented.* For most cases, `poll_event/1` should be sufficient.
  """
  def peek_event(pid, _timeout) when is_pid(pid) do
    raise("NIF peek_event/1 not implemented")
  end
end
