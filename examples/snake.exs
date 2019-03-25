# An example that shows how to make a game with Ratatouille by using the canvas
# element.
#
# Run this example with:
#
#   mix run examples/snake.exs

defmodule Snake do
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Subscription

  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @up key(:arrow_up)
  @down key(:arrow_down)
  @left key(:arrow_left)
  @right key(:arrow_right)
  @arrows [@up, @down, @left, @right]

  @initial_length 4

  def init(%{window: window}) do
    %{
      direction: :right,
      chain: for(x <- @initial_length..1, do: {x, 0}),
      food: {7, 7},
      alive: true,
      height: window.height - 2,
      width: window.width - 2
    }
  end

  def update(model, msg) do
    case msg do
      {:event, %{key: key}} when key in @arrows ->
        %{model | direction: next_dir(model.direction, key_to_dir(key))}

      :tick ->
        move_snake(model)

      _ ->
        model
    end
  end

  def subscribe(_model) do
    Subscription.interval(100, :tick)
  end

  def render(%{chain: chain} = model) do
    score = length(chain) - 4

    view do
      panel(
        title: "SNAKE (Move with the arrow keys) Score=#{score}",
        height: :fill,
        padding: 0
      ) do
        render_board(model)
      end
    end
  end

  defp render_board(%{alive: false}) do
    label(content: "Game Over")
  end

  defp render_board(
         %{
           chain: [{head_x, head_y} | tail],
           food: {food_x, food_y}
         } = model
       ) do
    head_cell = canvas_cell(x: head_x, y: head_y, char: "@")

    tail_cells = for {x, y} <- tail, do: canvas_cell(x: x, y: y, char: "O")

    food_cell = canvas_cell(x: food_x, y: food_y, char: "X")

    canvas(height: model.height, width: model.width) do
      [food_cell, head_cell | tail_cells]
    end
  end

  defp move_snake(model) do
    [head | tail] = model.chain
    next = next_link(head, model.direction)

    cond do
      not next_valid?(next, model) ->
        %{model | alive: false}

      next == model.food ->
        new_food = random_food(model.width - 1, model.height - 1)
        %{model | chain: [next, head | tail], food: new_food}

      true ->
        %{model | chain: [next, head | Enum.drop(tail, -1)]}
    end
  end

  defp random_food(max_x, max_y) do
    {Enum.random(0..max_x), Enum.random(0..max_y)}
  end

  defp key_to_dir(@up), do: :up
  defp key_to_dir(@down), do: :down
  defp key_to_dir(@left), do: :left
  defp key_to_dir(@right), do: :right

  defp next_valid?({x, y}, _model) when x < 0 or y < 0, do: false
  defp next_valid?({x, _y}, %{width: width}) when x >= width, do: false
  defp next_valid?({_x, y}, %{height: height}) when y >= height, do: false
  defp next_valid?(next, %{chain: chain}), do: next not in chain

  defp next_dir(:up, :down), do: :up
  defp next_dir(:down, :up), do: :down
  defp next_dir(:left, :right), do: :left
  defp next_dir(:right, :left), do: :right
  defp next_dir(_current, new), do: new

  defp next_link({x, y}, :up), do: {x, y - 1}
  defp next_link({x, y}, :down), do: {x, y + 1}
  defp next_link({x, y}, :left), do: {x - 1, y}
  defp next_link({x, y}, :right), do: {x + 1, y}
end

Ratatouille.run(Snake, interval: 100)
