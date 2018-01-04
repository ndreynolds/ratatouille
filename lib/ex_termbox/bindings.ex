defmodule ExTermbox.Bindings do
  alias ExTermbox.{Cell, Event, Position}

  @on_load :load_nifs

  def load_nifs do
    :erlang.load_nif('./priv/termbox_bindings', 0)
  end

  def init(),
    do: raise "NIF init/0 not implemented"

  def shutdown(),
    do: raise "NIF shutdown/0 not implemented"

  def width(),
    do: raise "NIF width/0 not implemented"

  def height(),
    do: raise "NIF height/0 not implemented"

  def clear(),
    do: raise "NIF clear/0 not implemented"

  def set_clear_attributes(_fg, _bg),
    do: raise "NIF set_clear_attributes/2 not implemented"

  def present(),
    do: raise "NIF present/0 not implemented"

  def set_cursor(_x, _y),
    do: raise "NIF set_cursor/2 not implemented"

  def put_cell(%Cell{position: %Position{x: x, y: y},
                     char: ch, fg: fg, bg: bg}),
    do: change_cell(x, y, ch, fg, bg)

  def change_cell(_x, _y, _ch, _fg, _bg),
    do: raise "NIF change_cell/5 not implemented"

  def select_input_mode(_mode),
    do: raise "NIF select_input_mode/1 not implemented"

  def select_output_mode(_mode),
    do: raise "NIF select_output_mode/1 not implemented"

  def peek_event(timeout),
    do: unpack_event(peek_event_raw(timeout))

  def poll_event,
    do: unpack_event(poll_event_raw())

  def poll_event_async(pid) when is_pid(pid),
    do: raise "NIF poll_event_async/1 not implemented"

  defp peek_event_raw(_timeout),
    do: raise "NIF peek_event_raw/1 not implemented"

  defp poll_event_raw(),
    do: raise "NIF poll_event_raw/0 not implemented"

  defp unpack_event({:error, _} = error), do: error
  defp unpack_event({:ok, event_tuple}) do
    {type, mod, key, ch, w, h, x, y} = event_tuple
    %Event{
      type: type, mod: mod, key: key, ch: ch,
      w: w, h: h, x: x, y: y
    }
  end
end
