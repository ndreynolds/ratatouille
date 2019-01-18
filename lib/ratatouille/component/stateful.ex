defmodule Ratatouille.Component.Stateful do
  @moduledoc """
  Defines the behaviour for a stateful view component.

  These components are inspired by React components. A module implementing the
  `Ratatouille.Component.Stateful` behaviour provides functions to transform
  state based on events and ticks, as well as a function to render an
  `Ratatouille.View` based on the state.

  Note that stateful components don't directly hold any state themselves, they
  only know how to use and transform it. The state should be stored in the main
  application loop.
  """

  alias ExTermbox.Event
  alias Ratatouille.View

  @type state :: term

  @doc """
  The `handle_event/2` callback provides an interface for reacting to window
  events by allowing the component to return a new or transformed state and
  trigger a re-render of that state.

  It's called with an `%ExTermbox.Event{}` struct and the current state.

  When pattern-matching events, components should always define a fallback
  `handle_event/2` clause such that unhandled key presses do not crash the
  window process.
  """
  @callback handle_event(Event.t(), state) :: {:ok, state} | {:error, term}

  @doc """
  The `tick/1` callback provides an interface for refreshing the state on some
  interval. This allows the component to update information that changes over
  time.
  """
  @callback handle_tick(state) :: {:ok, state} | {:error, term}

  @doc """
  The `render/1` callback provides an interface for rendering the component's
  view based on the current state.
  """
  @callback render(state) :: View.t()
end
