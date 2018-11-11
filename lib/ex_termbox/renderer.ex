defmodule ExTermbox.Renderer do
  @moduledoc """
  Logic to render a view tree.

  This API is still under development.
  """

  alias ExTermbox.Renderer.{
    Canvas,
    Element,
    Panel,
    Row,
    Sparkline,
    Table,
    Text,
    View
  }

  @type root_element :: %Element{
          tag: :view,
          children: list(child_element())
        }

  @type child_tag ::
          :column
          | :panel
          | :table
          | :sparkline
          | :bar
          | :row
          | :text
          | :label

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
  def render(%Canvas{} = canvas, %Element{tag: tag, children: children} = root) do
    with :ok <- validate_tree(tag, children) do
      {:ok, render_tree(canvas, root)}
    end
  end

  def render_tree(%Canvas{} = canvas, elements) when is_list(elements) do
    Enum.reduce(elements, canvas, fn el, new_canvas ->
      render_tree(new_canvas, el)
    end)
  end

  def render_tree(%Canvas{} = canvas, %Element{
        tag: tag,
        attributes: attrs,
        children: children
      }) do
    case tag do
      :view ->
        View.render(canvas, attrs, children, &render_tree/2)

      :row ->
        Row.render(canvas, children, &render_tree/2)

      :column ->
        render_tree(canvas, children)

      :panel ->
        Panel.render(canvas, attrs, &render_tree(&1, children))

      :table ->
        Table.render(canvas, children)

      :sparkline ->
        Sparkline.render(canvas, attrs)

      :bar ->
        render_tree(canvas, children)

      :label ->
        Text.render_group(canvas, children)
    end
  end

  ### View Tree Validation

  @valid_relationships %{
    view: [:row, :panel],
    row: [:column],
    column: [:panel, :table, :row, :label, :sparkline],
    panel: [:table, :row, :label, :sparkline],
    label: [:text],
    bar: [:label],
    table: [:table_row]
  }

  @doc """
  Validates the hierarchy of a view tree given the root element's tag and its
  children.

  Used by the render/2 function to prevent strange errors that may otherwise
  occur when processing invalid view trees.
  """
  def validate_tree(:view, children) do
    validate_subtree(:view, children)
  end

  def validate_tree(root_tag, _children) do
    {:error,
     "Invalid view hierarchy: Root element must have tag 'view', but found '#{
       root_tag
     }'"}
  end

  defp validate_subtree(parent, [%Element{tag: tag, children: children} | rest]) do
    with :ok <- validate_child(parent, tag),
         :ok <- validate_subtree(tag, children),
         :ok <- validate_subtree(parent, rest),
         do: :ok
  end

  defp validate_subtree(_parent, []) do
    :ok
  end

  defp validate_child(parent_tag, child_tag) do
    if child_tag in Map.get(@valid_relationships, parent_tag, []) do
      :ok
    else
      {:error,
       "Invalid view hierarchy: '#{child_tag}' cannot be a child of '#{
         parent_tag
       }'"}
    end
  end
end
