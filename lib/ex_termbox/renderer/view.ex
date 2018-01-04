defmodule ExTermbox.Renderer.View do
  alias ExTermbox.Renderer.{Element, View}

  @enforce_keys [:root_element]
  defstruct [:root_element]

  def new(child) do
    %View{root_element: child}
  end

  def element(tag, attributes, children) when is_atom(tag)
                                          and is_map(attributes)
                                          and is_list(children) do
    %Element{tag: tag, attributes: attributes, children: children}
  end

  def element(tag, children) when is_atom(tag) and is_list(children) do
    %Element{tag: tag, children: children}
  end

  def default_view do
    new(
      element(:column_layout, [
        element(:panel, %{title: "Welcome to ExTermbox"}, []),
        element(:panel, %{title: "Another Column"}, [])
      ])
    )
  end
end
