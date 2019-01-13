defmodule Ratatouille.Constants do
  @moduledoc """
  A convenience wrapper of `ExTermbox.Constants`.
  """

  alias ExTermbox.Constants, as: TermboxConstants

  defdelegate keys, to: TermboxConstants
  defdelegate key(k), to: TermboxConstants

  defdelegate colors, to: TermboxConstants
  defdelegate color(k), to: TermboxConstants

  defdelegate attributes, to: TermboxConstants
  defdelegate attribute(k), to: TermboxConstants

  defdelegate event_types, to: TermboxConstants
  defdelegate event_type(k), to: TermboxConstants

  defdelegate error_codes, to: TermboxConstants
  defdelegate error_code(k), to: TermboxConstants

  defdelegate input_modes, to: TermboxConstants
  defdelegate input_mode(k), to: TermboxConstants

  defdelegate output_modes, to: TermboxConstants
  defdelegate output_mode(k), to: TermboxConstants
end
