defmodule ExTermbox.Renderer.View do
  @moduledoc """
  Represents a renderable view of the terminal application.

  This API is still under development.
  """

  alias ExTermbox.Renderer.{Element, View}

  @enforce_keys [:root]
  defstruct root: nil,
            toolbar: nil

  def new(child) do
    %View{root: child}
  end

  def element(tag, attributes, children)
      when is_atom(tag) and is_map(attributes) and is_list(children) do
    %Element{tag: tag, attributes: attributes, children: children}
  end

  def element(tag, children) when is_atom(tag) and is_list(children) do
    %Element{tag: tag, children: children}
  end

  def default_view do
    new(
      element(:layout, %{type: :columned}, [
        element(:panel, %{title: "Welcome to ExTermbox"}, [
          element(:panel, %{title: "Nested panel"}, [
            element(:panel, %{title: "Nested panel"}, [])
          ])
        ]),
        element(:panel, %{title: "Welcome to ExTermbox"}, [
          element(:panel, %{title: "Nested panel"}, [
            element(:panel, %{title: "Nested panel"}, [])
          ])
        ])
      ])
    )
  end
end
