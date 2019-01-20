defmodule Ratatouille.Renderer do
  @moduledoc """
  Logic to render a view tree.

  This API is still under development.
  """

  alias Ratatouille.Renderer.{
    Canvas,
    Chart,
    Element,
    Label,
    Panel,
    Row,
    Sparkline,
    Table,
    Tree,
    View
  }

  @type root_element :: %Element{
          tag: :view,
          children: list(child_element())
        }

  @type child_tag ::
          :bar
          | :chart
          | :column
          | :label
          | :panel
          | :row
          | :sparkline
          | :table
          | :table_cell
          | :table_row
          | :text
          | :tree
          | :tree_node

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
  def render(%Canvas{} = canvas, %Element{} = root) do
    with :ok <- validate_tree(root) do
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

      :chart ->
        Chart.render(canvas, attrs)

      :sparkline ->
        Sparkline.render(canvas, attrs)

      :bar ->
        render_tree(canvas, children)

      :label ->
        Label.render(canvas, attrs, children)

      :tree ->
        Tree.render(canvas, children)
    end
  end

  ### View Tree Validation

  @valid_relationships %{
    view: [:row, :panel],
    row: [:column],
    column: [:panel, :table, :row, :label, :chart, :sparkline, :tree],
    panel: [:table, :row, :label, :panel, :chart, :sparkline, :tree],
    label: [:text],
    bar: [:label],
    table: [:table_row],
    table_cell: [:text],
    table_row: [:table_cell],
    tree: [:tree_node],
    tree_node: [:tree_node]
  }

  @doc """
  Validates the hierarchy of a view tree given the root element.

  Used by the render/2 function to prevent strange errors that may otherwise
  occur when processing invalid view trees.
  """
  def validate_tree(%Element{tag: :view, children: children}) do
    validate_subtree(:view, children)
  end

  def validate_tree(%Element{tag: tag}) do
    {:error,
     "Invalid view hierarchy: Root element must have tag 'view', but found '#{
       tag
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
