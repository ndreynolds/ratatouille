defmodule Ratatouille.Component.Stateless do
  @moduledoc """
  Defines the behaviour for a stateless view component.

  Unlike stateful components, stateless components cannot define event handlers
  or tick behavior. Stateless components define a `render/1` function that
  renders an `Ratatouille.View`. The concept is the same as React's functional
  components.

  While it's possible for stateless components to access global VM state, this
  is discouraged. They should render a view as a pure function of the given
  props.
  """

  alias Ratatouille.Renderer.Element

  @type props :: term

  @doc """
  The `render/1` callback provides an interface for rendering the component's
  view based on the current state.
  """
  @callback render(props) :: Element.t()
end
