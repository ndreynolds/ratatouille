defmodule ExTermbox.Renderer.Element do
  @enforce_keys [:tag]
  defstruct [tag: nil, attributes: %{}, children: []]
end
