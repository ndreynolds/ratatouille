defmodule ExTermbox.Renderer.StatusBar do
  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Box, Canvas}

  def render(%Canvas{box: box} = canvas, render_fun) do
    new_box = %Box{
      box
      | top_left: %Position{box.top_left | y: box.bottom_right.y}
    }

    %Canvas{canvas | box: new_box}
    |> render_fun.()
  end
end
