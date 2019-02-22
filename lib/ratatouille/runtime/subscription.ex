defmodule Ratatouille.Runtime.Subscription do
  @moduledoc """
  Subscriptions provide a way for the app to be notified via
  `c:Ratatouille.App.update/2` when something interesting happens.

  Subscriptions should be constructed via the functions below and not via the
  struct directly, as this is internal and subject to change.

  Currently, it's possible to subscribe to time intervals (`interval/2`) and to
  create batch subscriptions (i.e., multiple time intervals). More subscription
  types may be introduced later.

  ### Accuracy of Time Intervals

  Ratatouille's runtime loop, which handles subscriptions, runs on a interval
  itself (by default, every 500 ms). This means that the runtime loop is the
  minimum possible subscription interval. If a subscription's interval is more
  frequent than the runtime loop interval, the runtime loop interval is the
  subscription's effective interval.

  There is also no guarantee that subscriptions will be processed on time, as
  the runtime may be busy with other tasks (e.g., handling events or rendering).
  With that said, if care is taken to keep expensive calls out of the runtime
  loop, subscriptions should be processed very close to requested interval.
  """

  alias __MODULE__

  @enforce_keys [:type]
  defstruct [:type, :message, :data]

  @opaque t :: %__MODULE__{
            type: :interval | :batch,
            message: term(),
            data: term()
          }

  @doc """
  Returns a subscription based on a time interval. Takes the number of
  milliseconds (`ms`) and a message as arguments. When returned in the
  `c:Ratatouille.App.subscribe/1` callback, the runtime will call the
  `c:Ratatouille.App.update/2` function with current model and the message, on
  approximately the given interval. See above for details on what
  "approximately" means here.
  """
  @spec interval(non_neg_integer(), term()) :: Subscription.t()
  def interval(ms, message) do
    # Like 0, but accounts for a negative monotonic time
    last_at_ms = :erlang.monotonic_time(:millisecond) - ms
    %Subscription{type: :interval, data: {ms, last_at_ms}, message: message}
  end

  @doc """
  Creates a batch subscription from a list of subscriptions.

  This provides a way to subscribe to multiple things, while still returning a
  single subscription in `c:Ratatouille.App.subscribe/1`.
  """
  @spec batch([Subscription.t()]) :: Subscription.t()
  def batch([%Subscription{} | _] = subs) do
    %Subscription{type: :batch, data: subs}
  end

  @doc false
  def to_list(%Subscription{type: :batch, data: [sub | rest]}) do
    to_list(sub) ++ to_list(%Subscription{type: :batch, data: rest})
  end

  def to_list(%Subscription{type: :batch, data: []}), do: []

  def to_list(%Subscription{type: :interval} = sub), do: [sub]
end
