defmodule ExTermbox.Renderer.View do
  @moduledoc """
  Represents a renderable view of the terminal application.

  This API is still under development.
  """

  alias ExTermbox.Renderer.Element

  def view(children) do
    element(:view, children)
  end

  def element(tag, attributes, children)
      when is_atom(tag) and is_map(attributes) and is_list(children) do
    %Element{tag: tag, attributes: attributes, children: children}
  end

  def element(tag, children) when is_atom(tag) and is_list(children) do
    %Element{tag: tag, children: children}
  end
end
