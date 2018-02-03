defmodule RenderingDemo do
  alias ExTermbox.{EventManager, Event, Window}
  import ExTermbox.Renderer.View

  @refresh_interval 500

  def run do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    loop()
  end

  def loop do
    Window.update(demo_view())

    receive do
      {:event, %Event{ch: ?q}} -> :ok = Window.close()
    after @refresh_interval ->
      loop()
    end
  end

  def demo_view do
    view([
      element(:panel, %{title: "Rendering Demo"}, [
        element(:columned_layout, [
          element(:panel, %{title: "Column 1"}, [
            element(:table, [
              ["Current Time:", DateTime.utc_now() |> DateTime.to_string()],
            ]),
            element(:table, [
              ["Column 1", "Column 2", "Column 3"],
              ["a", "b", "c"],
              ["d", "e", "f"],
            ]),
            element(:table, [
              ["Random Number:", inspect(:rand.uniform())],
              ["Hello:", String.duplicate("World", Enum.random(1..3))]
            ])
          ]),
          element(:panel, %{title: "Column 2"}, [
            element(:sparkline, Enum.shuffle([0, 1, 2, 3, 4, 5, 6]))
          ])
        ])
      ])
    ])
  end
end

RenderingDemo.run()
