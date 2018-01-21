defmodule ExTermbox.Constants do
  @moduledoc """
  Defines constants from the termbox library. These can be used e.g. to set a
  formatting attributes or to identify keys passed in an event.
  """

  @keys %{
    f1: 0xFFFF - 0,
    f2: 0xFFFF - 1,
    f3: 0xFFFF - 2,
    f4: 0xFFFF - 3,
    f5: 0xFFFF - 4,
    f6: 0xFFFF - 5,
    f7: 0xFFFF - 6,
    f8: 0xFFFF - 7,
    f9: 0xFFFF - 8,
    f10: 0xFFFF - 9,
    f11: 0xFFFF - 10,
    f12: 0xFFFF - 11,
    insert: 0xFFFF - 12,
    delete: 0xFFFF - 13,
    home: 0xFFFF - 14,
    end: 0xFFFF - 15,
    pgup: 0xFFFF - 16,
    pgdn: 0xFFFF - 17,
    arrow_up: 0xFFFF - 18,
    arrow_down: 0xFFFF - 19,
    arrow_left: 0xFFFF - 20,
    arrow_right: 0xFFFF - 21,
    mouse_left: 0xFFFF - 22,
    mouse_right: 0xFFFF - 23,
    mouse_middle: 0xFFFF - 24,
    mouse_release: 0xFFFF - 25,
    mouse_wheel_up: 0xFFFF - 26,
    mouse_wheel_down: 0xFFFF - 27,
    ctrl_tilde: 0x00,
    # clash with 'CTRL_TILDE'
    ctrl_2: 0x00,
    ctrl_a: 0x01,
    ctrl_b: 0x02,
    ctrl_c: 0x03,
    ctrl_d: 0x04,
    ctrl_e: 0x05,
    ctrl_f: 0x06,
    ctrl_g: 0x07,
    backspace: 0x08,
    # clash with 'CTRL_BACKSPACE'
    ctrl_h: 0x08,
    tab: 0x09,
    # clash with 'TAB'
    ctrl_i: 0x09,
    ctrl_j: 0x0A,
    ctrl_k: 0x0B,
    ctrl_l: 0x0C,
    enter: 0x0D,
    # clash with 'ENTER'
    ctrl_m: 0x0D,
    ctrl_n: 0x0E,
    ctrl_o: 0x0F,
    ctrl_p: 0x10,
    ctrl_q: 0x11,
    ctrl_r: 0x12,
    ctrl_s: 0x13,
    ctrl_t: 0x14,
    ctrl_u: 0x15,
    ctrl_v: 0x16,
    ctrl_w: 0x17,
    ctrl_x: 0x18,
    ctrl_y: 0x19,
    ctrl_z: 0x1A,
    esc: 0x1B,
    # clash with 'ESC'
    ctrl_lsq_bracket: 0x1B,
    # clash with 'ESC'
    ctrl_3: 0x1B,
    ctrl_4: 0x1C,
    # clash with 'CTRL_4'
    ctrl_backslash: 0x1C,
    ctrl_5: 0x1D,
    # clash with 'CTRL_5'
    ctrl_rsq_bracket: 0x1D,
    ctrl_6: 0x1E,
    ctrl_7: 0x1F,
    # clash with 'CTRL_7'
    ctrl_slash: 0x1F,
    # clash with 'CTRL_7'
    ctrl_underscore: 0x1F,
    space: 0x20,
    backspace2: 0x7F,
    # clash with 'BACKSPACE2'
    ctrl_8: 0x7F
  }

  @colors %{
    default: 0x00,
    black: 0x01,
    red: 0x02,
    green: 0x03,
    yellow: 0x04,
    blue: 0x05,
    magenta: 0x06,
    cyan: 0x07,
    white: 0x08
  }

  @attributes %{
    bold: 0x0100,
    underline: 0x0200,
    reverse: 0x0400
  }

  @event_types %{
    key: 1,
    resize: 2,
    mouse: 3
  }

  @error_codes %{
    unsupported_terminal: -1,
    failed_to_open_tty: -2,
    pipe_trap_error: -3
  }

  @input_modes %{
    current: 0,
    esc: 1,
    alt: 2,
    mouse: 4
  }

  @output_modes %{
    current: 0,
    normal: 1,
    term_256: 2,
    term_216: 3,
    grayscale: 4
  }

  @hide_cursor -1

  def keys, do: @keys
  def colors, do: @colors
  def attributes, do: @attributes
  def event_types, do: @event_types
  def error_codes, do: @error_codes
  def input_modes, do: @input_modes
  def output_modes, do: @output_modes
  def hide_cursor, do: @hide_cursor
end
