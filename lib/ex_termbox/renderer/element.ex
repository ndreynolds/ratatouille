defmodule ExTermbox.Renderer.Element do
  @moduledoc false

  alias __MODULE__, as: Element

  @type t :: %Element{tag: atom()}

  @enforce_keys [:tag]
  defstruct tag: nil, attributes: %{}, children: []
end
