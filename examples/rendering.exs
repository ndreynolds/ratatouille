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
    after
      @refresh_interval ->
        loop()
    end
  end

  def demo_view do
    view do
      panel title: "Rendering Demo", height: :fill do
        columned_layout do
          panel title: "Column 1 Row 1" do
            table do
              table_row([
                "Current Time:",
                DateTime.utc_now() |> DateTime.to_string()
              ])
            end

            table do
              table_row(["Column 1", "Column 2", "Column 3"])
              table_row(["a", "b", "c"])
              table_row(["d", "e", "f"])
            end

            table do
              table_row(["Random Number:", inspect(:rand.uniform())])

              table_row(["Hello:", String.duplicate("World", Enum.random(1..3))])
            end
          end

          panel title: "Column 2 Row 1" do
            element(:sparkline, Enum.shuffle([0, 1, 2, 3, 4, 5, 6]))

            table do
              table_row([
                "Current Time:",
                DateTime.utc_now() |> DateTime.to_string()
              ])
            end

            table do
              table_row(["Column 1", "Column 2", "Column 3"])
              table_row(["a", "b", "c"])
              table_row(["d", "e", "f"])
            end

            table do
              table_row(["Random Number:", inspect(:rand.uniform())])

              table_row(["Hello:", String.duplicate("World", Enum.random(1..3))])
            end
          end
        end

        columned_layout do
          panel title: "Column 1 Row 2" do
            table do
              table_row([
                "Current Time:",
                DateTime.utc_now() |> DateTime.to_string()
              ])
            end

            table do
              table_row(["Column 1", "Column 2", "Column 3"])
              table_row(["a", "b", "c"])
              table_row(["d", "e", "f"])
            end

            table do
              table_row(["Random Number:", inspect(:rand.uniform())])

              table_row(["Hello:", String.duplicate("World", Enum.random(1..3))])
            end
          end

          panel title: "Column 2 Row 2" do
            element(:sparkline, Enum.shuffle([0, 1, 2, 3, 4, 5, 6]))

            table do
              table_row([
                "Current Time:",
                DateTime.utc_now() |> DateTime.to_string()
              ])
            end

            table do
              table_row(["Column 1", "Column 2", "Column 3"])
              table_row(["a", "b", "c"])
              table_row(["d", "e", "f"])
            end

            table do
              table_row(["Random Number:", inspect(:rand.uniform())])

              table_row(["Hello:", String.duplicate("World", Enum.random(1..3))])
            end
          end
        end
      end
    end
  end
end

RenderingDemo.run()
