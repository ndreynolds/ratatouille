defmodule ExTermbox.Renderer.View do
  @moduledoc """
  Represents a renderable view of the terminal application.

  This API is still under development.
  """

  alias ExTermbox.Renderer.{Box, Canvas, Element}

  ### View Rendering

  def render(canvas, attrs, children, render_fn) do
    canvas
    |> render_top_bar(attrs[:top_bar], render_fn)
    |> render_bottom_bar(attrs[:bottom_bar], render_fn)
    |> render_fn.(children)
  end

  defp render_top_bar(canvas, nil, _render_fn), do: canvas

  defp render_top_bar(%Canvas{box: box} = canvas, bar, render_fn) do
    canvas
    |> Canvas.put_box(Box.head(box, 1))
    |> render_fn.(bar)
    |> Canvas.put_box(box)
    |> Canvas.consume_rows(1)
  end

  defp render_bottom_bar(canvas, nil, _render_fn), do: canvas

  defp render_bottom_bar(%Canvas{box: box} = canvas, bar, render_fn) do
    canvas
    |> Canvas.put_box(Box.tail(box, 1))
    |> render_fn.(bar)
    |> Canvas.put_box(box)
    |> Canvas.consume_rows(1)
  end

  ### Element Definition

  def element(tag, attributes_or_children) do
    if Keyword.keyword?(attributes_or_children) || is_map(attributes_or_children),
      do: element(tag, attributes_or_children, []),
      else: element(tag, %{}, attributes_or_children)
  end

  def element(tag, attributes, children)
      when is_atom(tag) and is_map(attributes) and is_list(children) do
    %Element{tag: tag, attributes: attributes, children: List.flatten(children)}
  end

  def element(tag, attributes, %Element{} = child) do
    element(tag, attributes, [child])
  end

  def element(tag, attributes, children) when is_list(attributes) do
    element(tag, Enum.into(attributes, %{}), children)
  end

  ### Element Definition Macros

  @element_types [
    :bar,
    :chart,
    :column,
    :label,
    :panel,
    :row,
    :sparkline,
    :table,
    :table_row,
    :text,
    :tree,
    :tree_node,
    :view
  ]

  @empty_attrs Macro.escape(%{})
  @empty_children Macro.escape([])

  # To reduce boilerplate and provide a clean DSL for defining elements with
  # blocks, we support the following forms for each element type by generating
  # macros:
  #
  # Element with tag `foo`
  #
  #     foo()
  #
  # Element with tag `foo` with attributes
  #
  #     foo(size: 42)
  #
  # Element with tag `foo` with children as list
  #
  #     foo([
  #       bar()
  #     ])
  #
  # Element with tag `foo` with children as block
  #
  #     foo do
  #       bar()
  #     end
  #
  # Element with tag `foo` with attributes and children as list
  #
  #     foo(
  #       [size: 42],
  #       [bar()]
  #     )
  #
  # Element with tag `foo` with attributes and children as block
  #
  #     foo size: 42 do
  #       bar()
  #     end
  #
  for name <- @element_types do
    defmacro unquote(name)() do
      macro_element(unquote(name), @empty_attrs, @empty_children)
    end

    defmacro unquote(name)(do: block) do
      macro_element(unquote(name), @empty_children, block)
    end

    defmacro unquote(name)(attributes_or_children) do
      macro_element(unquote(name), attributes_or_children)
    end

    defmacro unquote(name)(attributes, do: block) do
      macro_element(unquote(name), attributes, block)
    end

    defmacro unquote(name)(attributes, children) do
      macro_element(unquote(name), attributes, children)
    end
  end

  defp macro_element(tag, attributes_or_children) do
    quote do
      element(unquote(tag), unquote(attributes_or_children))
    end
  end

  defp macro_element(tag, attributes, block) do
    child_elements = extract_children(block)

    quote do
      element(unquote(tag), unquote(attributes), unquote(child_elements))
    end
  end

  defp extract_children({:__block__, _meta, elements}), do: elements
  defp extract_children(element), do: element
end
