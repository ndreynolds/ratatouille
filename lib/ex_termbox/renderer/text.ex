defmodule ExTermbox.Renderer.Text do
  @moduledoc """
  Primitives for rendering text
  """

  alias ExTermbox.{Cell, Constants, Position}
  alias ExTermbox.Renderer.{Canvas, Element, Utils}

  use Bitwise

  def render(canvas, %Position{} = position, text, attrs \\ %{})
      when is_binary(text) do
    template = template_cell(attrs)
    cell_gen = Utils.cell_generator(position, :horizontal, template)

    text
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(cell_gen)
    |> Utils.render_cells(canvas)
  end

  def render_group(canvas, text_elements) do
    %Canvas{
      Enum.reduce(text_elements, canvas, &render_group_member/2)
      | box: canvas.box
    }
    |> Canvas.translate(0, 1)
  end

  defp render_group_member(
         %Element{tag: :text, attributes: attrs, children: [text]},
         canvas
       ) do
    canvas
    |> render(canvas.box.top_left, text, attrs)
    |> Canvas.translate(String.length(text), 0)
  end

  defp template_cell(attrs) do
    %Cell{
      bg: attrs[:background] || Constants.colors().default,
      fg: foreground(attrs),
      char: nil,
      position: nil
    }
  end

  defp foreground(attrs) do
    # FIXME: support light colorschemes, fetch "default" foreground here.
    base = attrs[:color] || Constants.colors().white
    flags = attrs[:attributes] || []
    Enum.reduce(flags, base, fn flag, acc -> acc ||| flag end)
  end
end
