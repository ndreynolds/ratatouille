defmodule Ratatouille.Renderer.Text do
  @moduledoc """
  Primitives for rendering text
  """

  alias ExTermbox.{Cell, Constants, Position}
  alias Ratatouille.Renderer.{Canvas, Element, Utils}

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
    |> Canvas.consume_rows(1)
  end

  defp render_group_member(
         %Element{tag: :text, attributes: attrs, children: []},
         canvas
       ) do
    text = attrs[:content] || ""

    canvas
    |> render(canvas.box.top_left, text, attrs)
    |> Canvas.translate(String.length(text), 0)
  end

  defp template_cell(attrs) do
    %Cell{
      bg: attrs[:background] || Constants.color(:default),
      fg: foreground(attrs),
      ch: nil,
      position: nil
    }
  end

  defp foreground(attrs) do
    base = attrs[:color] || Constants.color(:default)
    flags = attrs[:attributes] || []
    Enum.reduce(flags, base, fn flag, acc -> acc ||| flag end)
  end
end
