# Ratatouille

[![Hex.pm](https://img.shields.io/hexpm/v/ratatouille.svg)](https://hex.pm/packages/ratatouille)
[![Hexdocs.pm](https://img.shields.io/badge/api-hexdocs-brightgreen.svg)](https://hexdocs.pm/ratatouille)

Ratatouille is a declarative terminal UI kit for Elixir for building rich
text-based terminal applications similar to how you write HTML.

It builds on top of the [termbox](https://github.com/nsf/termbox) API (using the
Elixir bindings from [ex_termbox](https://github.com/ndreynolds/ex_termbox)].

For the API Reference, see: [https://hexdocs.pm/ratatouille](https://hexdocs.pm/ratatouille).

## Getting Started

TODO - Add examples & screenshots here.

## Installation

### From Hex

Add Ratatouille as a dependency in your project's `mix.exs`:

```elixir
def deps do
  [
    {:ratatouille, "~> 0.1.0"}
  ]
end
```

### From Source

To try out the master branch, first clone the repo:

```bash
git clone https://github.com/ndreynolds/ratatouille.git
cd ratatouille
```

Next, fetch the deps:

```
mix deps.get
```

Finally, try out one of the included [`examples/`](examples):

```
mix run examples/rendering.exs > debug.log
```

If you see lots of things drawn on your terminal screen, you're good to go. Use
"q" to quit in the examples.
