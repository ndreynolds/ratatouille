defmodule Ratatouille.Constants do
  @moduledoc """
  A convenience wrapper of `ExTermbox.Constants`.
  """

  alias ExTermbox.Constants, as: TermboxConstants

  defdelegate keys, to: TermboxConstants
  defdelegate key(name), to: TermboxConstants

  defdelegate colors, to: TermboxConstants
  defdelegate color(name), to: TermboxConstants

  defdelegate attributes, to: TermboxConstants
  defdelegate attribute(name), to: TermboxConstants

  defdelegate event_types, to: TermboxConstants
  defdelegate event_type(name), to: TermboxConstants

  defdelegate error_codes, to: TermboxConstants
  defdelegate error_code(name), to: TermboxConstants

  defdelegate input_modes, to: TermboxConstants
  defdelegate input_mode(name), to: TermboxConstants

  defdelegate output_modes, to: TermboxConstants
  defdelegate output_mode(name), to: TermboxConstants
end
