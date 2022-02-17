defmodule Expat.MixProject do
  use Mix.Project

  def project do
    [
      app: :expat,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Expat, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      {:docker, git: "https://github.com/hexedpackets/docker-elixir.git", tag: "0.4.0"},
      {:yaml_elixir, "~> 2.8.0"},
    ]
  end
end
