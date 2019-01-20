defmodule Ratatouille.Constants do
  @moduledoc """
  A convenience wrapper of `ExTermbox.Constants`.
  """

  alias ExTermbox.Constants, as: TermboxConstants

  @constant_types [
    {:key, :keys},
    {:color, :colors},
    {:attribute, :attributes},
    {:event_type, :event_types},
    {:error_code, :error_codes},
    {:input_mode, :input_modes},
    {:output_mode, :output_modes}
  ]

  for {lookup, collection} <- @constant_types do
    @doc """
    See `ExTermbox.Constants.#{lookup}/1`.
    """
    defdelegate unquote(lookup)(name), to: TermboxConstants

    @doc """
    See `ExTermbox.Constants.#{collection}/1`.
    """
    defdelegate unquote(collection)(), to: TermboxConstants
  end
end
