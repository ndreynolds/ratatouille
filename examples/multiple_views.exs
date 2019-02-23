# An example of how to implement navigation between multiple views.
#
# Run this example with:
#
#   mix run examples/multiple_views.exs

defmodule MultipleViewsDemo do
  @behaviour Ratatouille.App

  import Ratatouille.Constants, only: [color: 1]
  import Ratatouille.View

  def init(_context) do
    %{selected_tab: 1}
  end

  def update(model, message) do
    case message do
      {:event, %{ch: ?1}} -> %{model | selected_tab: 1}
      {:event, %{ch: ?2}} -> %{model | selected_tab: 2}
      {:event, %{ch: ?3}} -> %{model | selected_tab: 3}
      _ -> model
    end
  end

  def render(model) do
    view top_bar: title_bar(), bottom_bar: status_bar(model.selected_tab) do
      case model.selected_tab do
        1 -> panel(title: "View 1", height: :fill)
        2 -> panel(title: "View 2", height: :fill)
        3 -> panel(title: "View 3", height: :fill)
      end
    end
  end

  def title_bar do
    bar do
      label(content: "Multiple Views Demo (Press 1, 2 or 3, or q to quit)")
    end
  end

  def status_bar(selected) do
    bar do
      label do
        for item <- 1..3 do
          if item == selected do
            text(
              background: color(:white),
              color: color(:black),
              content: " View #{item} "
            )
          else
            text(content: " View #{item} ")
          end
        end
      end
    end
  end
end

Ratatouille.run(MultipleViewsDemo)
