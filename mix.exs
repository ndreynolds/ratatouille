defmodule Ratatouille.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ndreynolds/ratatouille"
  @version "0.5.1"

  def project do
    [
      app: :ratatouille,
      name: "Ratatouille",
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      aliases: aliases(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_termbox, "~> 1.0"},
      {:asciichart, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyze, "~> 0.2.0", only: :dev},
      {:credo, "~> 1.3.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      description: "A declarative terminal UI kit for Elixir",
      files: ~w(lib pages mix.exs README.md CHANGELOG.md LICENSE),
      maintainers: ["Nick Reynolds"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/ratatouille/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp aliases do
    [
      test: "test --exclude integration"
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"],
        "pages/under-the-hood.md": []
      ],
      main: "readme",
      assets: "assets",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
