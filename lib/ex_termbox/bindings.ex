defmodule ExTermbox.Bindings do
  alias ExTermbox.{Cell, Position}

  @on_load :load_nifs

  def load_nifs do
    so_path = Path.join(:code.priv_dir(:ex_termbox), "termbox_bindings")
    :erlang.load_nif(so_path, 0)
  end

  def init do
    raise("NIF init/0 not implemented")
  end

  def shutdown do
    raise("NIF shutdown/0 not implemented")
  end

  def width do
    raise("NIF width/0 not implemented")
  end

  def height do
    raise("NIF height/0 not implemented")
  end

  def clear do
    raise("NIF clear/0 not implemented")
  end

  def set_clear_attributes(_fg, _bg) do
    raise("NIF set_clear_attributes/2 not implemented")
  end

  def present do
    raise("NIF present/0 not implemented")
  end

  def set_cursor(_x, _y) do
    raise("NIF set_cursor/2 not implemented")
  end

  def put_cell(%Cell{position: %Position{x: x, y: y}, char: ch, fg: fg, bg: bg}) do
    change_cell(x, y, ch, fg, bg)
  end

  def change_cell(_x, _y, _ch, _fg, _bg) do
    raise("NIF change_cell/5 not implemented")
  end

  def select_input_mode(_mode) do
    raise("NIF select_input_mode/1 not implemented")
  end

  def select_output_mode(_mode) do
    raise("NIF select_output_mode/1 not implemented")
  end

  def poll_event(pid) when is_pid(pid) do
    raise("NIF poll_event/1 not implemented")
  end

  def peek_event(pid, _timeout) when is_pid(pid) do
    raise("NIF peek_event/1 not implemented")
  end
end
