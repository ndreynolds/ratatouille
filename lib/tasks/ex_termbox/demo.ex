defmodule Mix.Tasks.ExTermbox.Demo do
  @moduledoc """
  A demo of the library's functionality
  """

  use Mix.Task

  alias ExTermbox.{EventManager, Event, Window}
  alias ExTermbox.Renderer.{View}

  require Logger

  def run(_) do
    Logger.add_backend({LoggerFileBackend, :debug})

    Logger.configure_backend(
      {LoggerFileBackend, :debug},
      path: "extb_debug.log"
    )

    Logger.configure_backend(:console, level: :error)

    {:ok, _} = Window.start_link()
    {:ok, _} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    spawn(&refresh_loop/0)
    event_loop()
  end

  def refresh_loop do
    Window.update(view())
    :timer.sleep(500)
    refresh_loop()
  end

  def event_loop do
    receive do
      {:event, %Event{ch: ?q}} ->
        :ok = Window.close()
        IO.puts("closed window")

      {:event, %Event{} = event} ->
        Logger.info("Received event: #{inspect(event)}")
        event_loop()
    end
  end

  def view do
    View.new(
      View.element(:columned_layout, [
        View.element(:panel, %{title: "Welcome to ExTermbox"}, [
          View.element(:table, [
            ["Current Time:", DateTime.utc_now() |> DateTime.to_string()],
            ["Current Time 2:", DateTime.utc_now() |> DateTime.to_string()]
          ]),
          View.element(:table, [
            ["Current Time:", DateTime.utc_now() |> DateTime.to_string()],
            ["Current Time 2:", DateTime.utc_now() |> DateTime.to_string()],
            ["Current Time 3:", DateTime.utc_now() |> DateTime.to_string()],
            ["Current Time 4:", DateTime.utc_now() |> DateTime.to_string()]
          ]),
          View.element(:table, [
            ["Current Time:", DateTime.utc_now() |> DateTime.to_string()],
            ["Current Time 2:", DateTime.utc_now() |> DateTime.to_string()]
          ]),
          View.element(:sparkline, Enum.shuffle([
            0, 1, 2, 3, 4, 5, 6
          ]))
        ])
      ])
    )
  end
end
