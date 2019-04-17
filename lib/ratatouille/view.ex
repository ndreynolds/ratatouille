defmodule Ratatouille.View do
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

  ### Validation

  While some errors---such as passing children to empty elements---are prevented
  by the DSL, it's still possible (for now, at least) to build
  semantically-invalid element trees using the DSL. This means that the elements
  are being used in a way that doesn't make sense to the renderer.

  In order to prevent cryptic rendering errors, the renderer first validates the
  element tree it's given and rejects the whole thing if the structure is
  unsupported. It currently checks the following things:

  * The top-level element passed to the renderer must have the `:view` tag.
  * A parent element may only have child elements that have one of the
    supported child tags for the parent element.
  * An element must define all of its required attributes and may not define any
    unknown attributes.

  The last two rules are based on the element's specification in
  `Ratatouille.Renderer.Element`.
  """

  alias Ratatouille.Renderer.Element

  ### Element Definition

  def element(tag, attributes_or_children) do
    if Keyword.keyword?(attributes_or_children) ||
         is_map(attributes_or_children),
       do: element(tag, attributes_or_children, []),
       else: element(tag, %{}, attributes_or_children)
  end

  def element(tag, attributes, children)
      when is_atom(tag) and is_map(attributes) and is_list(children) do
    %Element{
      tag: tag,
      attributes: attributes,
      children: flatten_children(children)
    }
  end

  def element(tag, attributes, %Element{} = child) do
    element(tag, attributes, [child])
  end

  def element(tag, attributes, children) when is_list(attributes) do
    element(tag, Enum.into(attributes, %{}), children)
  end

  defp flatten_children(children) do
    children
    |> List.flatten()
    |> Enum.filter(&(!is_nil(&1)))
  end

  ### Element Definition Macros

  @empty_attrs Macro.escape(%{})
  @empty_children Macro.escape([])

  for {name, spec} <- Element.specs() do
    attributes_content =
      case spec[:attributes] do
        [] ->
          "None"

        attributes ->
          for {attr, {type, desc}} <- attributes do
            "* `#{attr}` (#{type}) - #{desc}"
          end
          |> Enum.join("\n")
      end

    if length(spec[:child_tags]) > 0 do
      allowed_children_content =
        for child <- spec[:child_tags] do
          "* #{child}"
        end
        |> Enum.join("\n")

      @doc """
      Defines an element with the `:#{name}` tag.

      ## Allowed Child Elements

      #{allowed_children_content}

      ## Examples

      Empty element:

          #{name}()

      With a block:

          #{name} do
            # ...child elements...
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

      ## Attributes

      #{attributes_content}

      ## Allowed Child Elements

      #{allowed_children_content}

      ## Examples

      Passing attributes:

          #{name}(key: value)

      Passing attributes and a block:

          #{name}(key: value) do
            # ...child elements...
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

      ## Attributes

      #{attributes_content}

      ## Allowed Child Elements

      #{allowed_children_content}

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

      ## Attributes

      #{attributes_content}

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
