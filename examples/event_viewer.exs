defmodule EventViewer do
  @moduledoc """
  A sample application that shows debug information about terminal events. These
  can be click, resize or key press events.
  """

  alias ExTermbox.Event
  alias Ratatouille.{Constants, EventManager, Window}

  import Ratatouille.Renderer.View

  @title "Event Viewer (click, resize, or press a key - 'q' to quit)"

  def run do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    Window.update(layout())
    loop()
  end

  def loop do
    receive do
      {:event, %Event{ch: ?q}} ->
        :ok = Window.close()

      {:event, %Event{} = event} ->
        Window.update(event_view(event))
        loop()
    end
  end

  def event_view(%Event{
        type: type,
        mod: mod,
        key: key,
        ch: ch,
        w: w,
        h: h,
        x: x,
        y: y
      }) do
    type_name = reverse_lookup(Constants.event_types(), type)

    key_name =
      if key != 0,
        do: reverse_lookup(Constants.keys(), key),
        else: :none

    layout([
      table do
        table_row(values: ["Type", inspect(type), inspect(type_name)])
        table_row(values: ["Mod", inspect(mod), ""])
        table_row(values: ["Key", inspect(key), inspect(key_name)])
        table_row(values: ["Char", inspect(ch), <<ch::utf8>>])
        table_row(values: ["Width", inspect(w), ""])
        table_row(values: ["Height", inspect(h), ""])
        table_row(values: ["X", inspect(x), ""])
        table_row(values: ["Y", inspect(y), ""])
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

EventViewer.run()
