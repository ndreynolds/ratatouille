defmodule Mix.Tasks.ExTermbox.Demo do
  use Mix.Task

  alias ExTermbox.{EventManager, Event, Window, Bindings}
  alias ExTermbox.Renderer
  alias ExTermbox.Renderer.{View}

  def run(_) do
    {:ok, _pid} = Window.start_link()
    :ok = Window.open()
    {:ok, pid} = EventManager.start_link()
    :ok = EventManager.subscribe(pid, self())

    event_loop()
  end

  def event_loop do
    receive do
      {:event, %Event{ch: ?q}} ->
        :ok = Window.close()
      {:event, %Event{} = event} ->
        view = View.new(
          View.element(:column_layout, [
            View.element(:panel, %{title: "Input Received"}, []),
            View.element(:panel, %{title: "Received #{inspect(event)}"}, [])
          ])
        )
        Window.update(view)
        event_loop()
    end
  end
end
