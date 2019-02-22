# A sample application that shows debug information about terminal events.
# These can be click, resize or key press events.

defmodule EventViewer do
  alias Ratatouille.{EventManager, Window}

  import Ratatouille.View
  import Ratatouille.Constants

  @title "Event Viewer (click, resize, or press a key - 'q' to quit)"
  @input_mode input_mode(:esc_with_mouse)

  def start do
    {:ok, _pid} = Window.start_link(input_mode: @input_mode)
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    Window.update(layout())
    loop()
  end

  def loop do
    receive do
      {:event, %{ch: ?q}} ->
        :ok = Window.close()

      {:event, %{} = event} ->
        Window.update(event_view(event))
        loop()
    end
  end

  def event_view(%{
        type: type,
        mod: mod,
        key: key,
        ch: ch,
        w: w,
        h: h,
        x: x,
        y: y
      }) do
    type_name = reverse_lookup(event_types(), type)

    key_name =
      if key != 0,
        do: reverse_lookup(keys(), key),
        else: :none

    layout([
      table do
        table_row do
          table_cell(content: "Type")
          table_cell(content: inspect(type))
          table_cell(content: inspect(type_name))
        end

        table_row do
          table_cell(content: "Mod")
          table_cell(content: inspect(mod))
          table_cell()
        end

        table_row do
          table_cell(content: "Key")
          table_cell(content: inspect(key))
          table_cell(content: inspect(key_name))
        end

        table_row do
          table_cell(content: "Char")
          table_cell(content: inspect(ch))
          table_cell(content: <<ch::utf8>>)
        end

        table_row do
          table_cell(content: "Width")
          table_cell(content: inspect(w))
          table_cell()
        end

        table_row do
          table_cell(content: "Height")
          table_cell(content: inspect(h))
          table_cell()
        end

        table_row do
          table_cell(content: "X")
          table_cell(content: inspect(x))
          table_cell()
        end

        table_row do
          table_cell(content: "Y")
          table_cell(content: inspect(y))
          table_cell()
        end
      end
    ])
  end

  def layout(children \\ []) do
    view do
      panel([title: @title, height: :fill], children)
    end
  end

  def reverse_lookup(map, val) do
    map |> Enum.find(fn {_, v} -> v == val end) |> elem(0)
  end
end

EventViewer.start()
