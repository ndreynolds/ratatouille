defmodule Ratatouille.Renderer.View do
  @moduledoc """
  In Ratatouille, a view is simply a tree of elements. Each element in the tree
  holds an attributes map and a list of zero or more child nodes. Visually, it
  looks like something this:

      %Element{
        tag: :view,
        attributes: %{},
        children: [
          %Element{
            tag: :row,
            attributes: %{},
            children: [
              %Element{tag: :column, attributes: %{size: 4}, children: []},
              %Element{tag: :column, attributes: %{size: 4}, children: []},
              %Element{tag: :column, attributes: %{size: 4}, children: []}
            ]
          }
        ]
      }

  ## View DSL

  Because it's a bit tedious to define views like that, Ratatouille provides a
  DSL to define them without all the boilerplate.

  Now we can turn the above into this:

      view do
        row do
          column(size: 4)
          column(size: 4)
          column(size: 4)
        end
      end

  While the syntax is more compact, the end result is exactly the same. This
  expression produces the exact same `%Element{}` struct as defined above.

  To use the DSL like this, we need to import all the functions:

      import Ratatouille.View

  Alternatively, import just the ones you need:

      import Ratatouille.View, only: [view: 0, row: 0, column: 1]

  ### Forms

  All of the possible forms are enumerated below.

  Element with tag `foo`:

      foo()

  Element with tag `foo` and attributes:

      foo(size: 42)

  Element with tag `foo` and children as list:

      foo([
        bar()
      ])

  Element with tag `foo` and children as block:

      foo do
        bar()
      end

  Element with tag `foo`, attributes, and children as list:

      foo(
        [size: 42],
        [bar()]
      )

  Element with tag `foo`, attributes, and children as block:

      foo size: 42 do
        bar()
      end

  ### Empty Elements

  Similar to so-called "empty" HTML elements such as `<br />`, Ratatouille also
  has elements for which passing content doesn't make sense. For example, the
  leaf node `text` stores its content in its attributes and cannot have any
  child elements of its own.

  In such cases, the block and list forms are unsupported.
  """

  alias Ratatouille.Renderer.{Box, Canvas, Element}

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
    if Keyword.keyword?(attributes_or_children) ||
         is_map(attributes_or_children),
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

  @empty_attrs Macro.escape(%{})
  @empty_children Macro.escape([])

  for {name, spec} <- Element.specs() do
    if length(spec[:child_tags]) > 0 do
      @doc """
      Defines an element with the `:#{name}` tag.

      ## Examples

      Empty element:

          #{name}()

      With a block:

          #{name} do
            bar()
          end

      """
      defmacro unquote(name)() do
        macro_element(unquote(name), @empty_attrs, @empty_children)
      end

      defmacro unquote(name)(do: block) do
        macro_element(unquote(name), @empty_children, block)
      end

      @doc """
      Defines an element with the `:#{name}` tag and either:

      * given attributes and an optional block
      * a list of child elements

      ## Examples

      Passing attributes:

          #{name}(key: value)

      Passing attributes and a block:

          #{name}(key: value) do
            bar()
          end

      Passing list of children:

          #{name}([elem1, elem2])

      """
      defmacro unquote(name)(attributes_or_children) do
        macro_element(unquote(name), attributes_or_children)
      end

      defmacro unquote(name)(attributes, do: block) do
        macro_element(unquote(name), attributes, block)
      end

      @doc """
      Defines an element with the `:#{name}` tag and the given attributes and
      child elements.

      ## Examples

          #{name}([key: value], [elem1, elem2])

      """
      defmacro unquote(name)(attributes, children) do
        macro_element(unquote(name), attributes, children)
      end
    else
      @doc """
      Defines an element with the `:#{name}` tag.

      ## Examples

      Empty element:

          #{name}()

      """
      defmacro unquote(name)() do
        macro_element(unquote(name), @empty_attrs, @empty_children)
      end

      @doc """
      Defines an element with the `:#{name}` tag and the given attributes.

      ## Examples

          #{name}(key: value)
      """
      defmacro unquote(name)(attributes) do
        macro_element(unquote(name), attributes, [])
      end
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
