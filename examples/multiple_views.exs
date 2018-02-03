defmodule ToolbarDemo do
  alias ExTermbox.{Constants, EventManager, Event, Window}
  import ExTermbox.Renderer.View

  def run do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    loop(view_1())
  end

  def loop(view) do
    Window.update(view)

    receive do
      {:event, %Event{ch: ?q}} ->
        :ok = Window.close()

      {:event, %Event{ch: ?1}} ->
        loop(view_1())

      {:event, %Event{ch: ?2}} ->
        loop(view_2())

      {:event, %Event{ch: ?3}} ->
        loop(view_3())
    end
  end

  def view_1 do
    element(:view, [
      element(:panel, %{title: "View 1"}, []),
      status_bar("View 1")
    ])
  end

  def view_2 do
    element(:view, [
      element(:panel, %{title: "View 2"}, []),
      status_bar("View 2")
    ])
  end

  def view_3 do
    element(:view, [
      element(:panel, %{title: "View 3"}, []),
      status_bar("View 3")
    ])
  end

  def status_bar(selected) do
    element(:status_bar, [
      element(
        :text_group,
        ["View 1", "View 2", "View 3"]
        |> Enum.map(fn opt ->
          element(:text, if(opt == selected, do: highlighted(), else: %{}), [
            opt
          ])
        end)
        |> Enum.intersperse(element(:text, [" "]))
      )
    ])
  end

  def highlighted do
    %{
      background: Constants.color(:white),
      color: Constants.color(:black)
    }
  end
end

ToolbarDemo.run()
