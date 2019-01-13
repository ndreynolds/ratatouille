defmodule MultipleViewsDemo do
  @moduledoc """
  An example of how to implement navigation between multiple views.
  """

  alias ExTermbox.{EventManager, Event}
  alias Ratatouille.Window

  import ExTermbox.Constants, only: [color: 1]
  import Ratatouille.Renderer.View

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
    view(top_bar: title_bar(), bottom_bar: status_bar_for("View 1")) do
      panel(title: "View 1", height: :fill)
    end
  end

  def view_2 do
    view(top_bar: title_bar(), bottom_bar: status_bar_for("View 2")) do
      panel(title: "View 2", height: :fill)
    end
  end

  def view_3 do
    view(top_bar: title_bar(), bottom_bar: status_bar_for("View 3")) do
      panel(title: "View 3", height: :fill)
    end
  end

  def title_bar do
    bar do
      label(content: "Multiple Views Demo (Press 1, 2 or 3, or q to quit)")
    end
  end

  @style_highlighted [
    background: color(:white),
    color: color(:black)
  ]

  def status_bar_for(selected) do
    options =
      for item <- Enum.intersperse(["View 1", "View 2", "View 3"], " ") do
        attrs = if(item == selected, do: @style_highlighted, else: [])
        text(attrs ++ [content: item])
      end

    bar do
      label(options)
    end
  end
end

MultipleViewsDemo.run()
