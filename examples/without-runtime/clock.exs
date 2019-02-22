# An example of how to create application loops.

defmodule Clock do
  alias Ratatouille.{EventManager, Window}

  import Ratatouille.View

  def start do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
    loop()
  end

  def loop do
    clock_view = render(DateTime.utc_now())
    Window.update(clock_view)

    receive do
      {:event, %{ch: ?q}} ->
        :ok = Window.close()
    after
      1_000 ->
        loop()
    end
  end

  def render(now) do
    view do
      panel title: "Clock Example ('q' to quit)" do
        label(content: "The time is: " <> DateTime.to_string(now))
      end
    end
  end
end

Clock.start()
