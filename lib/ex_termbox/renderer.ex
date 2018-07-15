defmodule ExTermbox.Renderer do
  @moduledoc """
  Logic to render a view tree.

  This API is still under development.
  """

  alias ExTermbox.Renderer.{
    Element,
    Canvas,
    Panel,
    Row,
    Sparkline,
    StatusBar,
    Table,
    Text
  }

  require Logger

  @type root_element :: %Element{
          tag: :view,
          children: list(child_element())
        }

  @type child_tag ::
          :columned_layout
          | :panel
          | :table
          | :sparkline
          | :status_bar
          | :text
          | :text_group

  @type child_element :: %Element{tag: child_tag()}

  @doc """
  Renders a view tree to canvas, given a canvas and a root element (an element
  with the `:view` tag).

  The tree is rendered by recursively rendering each element in the hierarchy.
  The canvas serves as both the accumulator for rendered cells at each stage and
  as the box representing available space for rendering, which shrinks as this
  space is consumed.
  """
  @spec render(Canvas.t(), root_element) :: {:ok, Canvas.t()} | {:error, term()}
  def render(%Canvas{} = canvas, %Element{tag: :view, children: children}) do
    with :ok <- validate_tree(:view, children) do
      {:ok, render_tree(canvas, children)}
    end
  end

  def render_tree(%Canvas{} = canvas, elements) when is_list(elements) do
    elements
    |> Enum.reduce(canvas, fn el, new_canvas -> render_tree(new_canvas, el) end)
  end

  def render_tree(%Canvas{} = canvas, %Element{
        tag: tag,
        attributes: attrs,
        children: children
      }) do
    case tag do
      :row ->
        Row.render(canvas, children, &render_tree/2)

      :column ->
        render_tree(canvas, children)

      :panel ->
        Panel.render(canvas, attrs, &render_tree(&1, children))

      :table ->
        Table.render(canvas, children)

      :sparkline ->
        Sparkline.render(canvas, children)

      :status_bar ->
        StatusBar.render(canvas, &render_tree(&1, children))

      :text ->
        [content] = children
        Text.render(canvas, canvas.box.top_left, content, attrs)

      :text_group ->
        Text.render_group(canvas, children)
    end
  end

  def validate_tree(parent, [%Element{tag: tag, children: children} | rest]) do
    with :ok <- validate_child(parent, tag),
         :ok <- validate_tree(tag, children),
         :ok <- validate_tree(parent, rest),
         do: :ok
  end

  def validate_tree(_parent, _x), do: :ok

  defp validate_child(parent, child) do
    case {parent, child} do
      {:view, child} when child in [:row, :status_bar, :panel] ->
        :ok

      {:row, :column} ->
        :ok

      {:column, child}
      when child in [:panel, :table, :row, :text, :text_group, :sparkline] ->
        :ok

      {:panel, child}
      when child in [:table, :row, :text, :text_group, :sparkline] ->
        :ok

      {:table, :table_row} ->
        :ok

      {_, _} ->
        {:error,
         "Invalid view hierarchy: '#{child}' cannot be a child of '#{parent}'"}
    end
  end
end
