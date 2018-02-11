defmodule EventViewer do
  alias ExTermbox.{Constants, EventManager, Event, Window}
  import ExTermbox.Renderer.View

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
      element(:table, [
        element(:table_row, ["Type", inspect(type), inspect(type_name)]),
        element(:table_row, ["Mod", inspect(mod), ""]),
        element(:table_row, ["Key", inspect(key), inspect(key_name)]),
        element(:table_row, ["Char", inspect(ch), <<ch::utf8>>]),
        element(:table_row, ["Width", inspect(w), ""]),
        element(:table_row, ["Height", inspect(h), ""]),
        element(:table_row, ["X", inspect(x), ""]),
        element(:table_row, ["Y", inspect(y), ""])
      ])
    ])
  end

  def layout(children \\ []) do
    title = "Event Viewer (click, resize, or press a key - 'q' to quit)"
    view([element(:panel, %{title: title, height: :fill}, children)])
  end

  def reverse_lookup(map, val) do
    map |> Enum.find(fn {_, v} -> v == val end) |> elem(0)
  end
end

EventViewer.run()
