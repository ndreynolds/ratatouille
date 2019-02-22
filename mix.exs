defmodule Ratatouille.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ratatouille,
      version: "0.3.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Ratatouille",
      source_url: "https://github.com/ndreynolds/ratatouille",
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_termbox, "~> 0.3"},
      {:asciichart, "~> 1.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyze, "~> 0.2.0", only: :dev},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "A declarative terminal UI kit for Elixir"
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Nick Reynolds"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ndreynolds/ratatouille"}
    ]
  end

  defp aliases do
    [
      test: "test --exclude integration",
      "test.integration": "test --only integration"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
