defmodule Ratatouille.Renderer do
  @moduledoc """
  Logic to render a view tree.

  This API is still under development.
  """

  alias Ratatouille.Renderer.{Canvas, Element}

  @type root_element :: %Element{
          tag: :view,
          children: list(child_element())
        }

  @type child_tag ::
          :bar
          | :chart
          | :column
          | :label
          | :overlay
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

  @callback render(
              Canvas.t(),
              Element.t(),
              (Canvas.t(), Element.t() -> Canvas.t())
            ) :: Canvas.t()

  @element_specs Element.specs()

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

  @spec render_tree(Canvas.t(), Element.t() | list(Element.t())) :: Canvas.t()
  def render_tree(%Canvas{} = canvas, elements) when is_list(elements) do
    Enum.reduce(elements, canvas, fn el, new_canvas ->
      render_tree(new_canvas, el)
    end)
  end

  def render_tree(
        %Canvas{} = canvas,
        %Element{tag: tag} = element
      ) do
    spec = Keyword.fetch!(@element_specs, tag)
    renderer = Keyword.fetch!(spec, :renderer)

    renderer.render(canvas, element, &render_tree/2)
  end

  ### View Tree Validation

  @doc """
  Validates the hierarchy of a view tree given the root element.

  Used by the render/2 function to prevent strange errors that may otherwise
  occur when processing invalid view trees.
  """
  @spec validate_tree(Element.t()) :: :ok | {:error, String.t()}
  def validate_tree(%Element{tag: :view, children: children}) do
    validate_subtree(:view, children)
  end

  def validate_tree(%Element{tag: tag}) do
    {:error,
     "Invalid view hierarchy: Root element must have tag 'view', but found '#{
       tag
     }'"}
  end

  defp validate_subtree(parent, [
         %Element{tag: tag, attributes: attributes, children: children} | rest
       ]) do
    with :ok <- validate_relationship(parent, tag),
         :ok <- validate_attributes(tag, attributes),
         :ok <- validate_subtree(tag, children),
         :ok <- validate_subtree(parent, rest),
         do: :ok
  end

  defp validate_subtree(_parent, []) do
    :ok
  end

  defp validate_attributes(tag, attributes) do
    spec = Keyword.fetch!(@element_specs, tag)
    attribute_specs = spec[:attributes] || []

    used_keys = Map.keys(attributes)
    valid_keys = Keyword.keys(attribute_specs)
    required_keys = for {key, {:required, _desc}} <- attribute_specs, do: key

    case {used_keys -- valid_keys, required_keys -- used_keys} do
      {[], []} ->
        :ok

      {invalid_keys, []} ->
        {:error,
         "Invalid attributes: '#{tag}' does not accept attributes #{
           inspect(invalid_keys)
         }"}

      {_, missing_keys} ->
        {:error,
         "Invalid attributes: '#{tag}' is missing required attributes #{
           inspect(missing_keys)
         }"}
    end
  end

  defp validate_relationship(parent_tag, child_tag) do
    valid_child_tags = @element_specs[parent_tag][:child_tags] || []

    if child_tag in valid_child_tags do
      :ok
    else
      {:error,
       "Invalid view hierarchy: '#{child_tag}' cannot be a child of '#{
         parent_tag
       }'"}
    end
  end
end
