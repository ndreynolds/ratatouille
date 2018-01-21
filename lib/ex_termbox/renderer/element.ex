defmodule ExTermbox.Renderer.Element do
  @moduledoc false

  @enforce_keys [:tag]
  defstruct tag: nil, attributes: %{}, children: []
end
