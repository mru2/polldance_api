defmodule PollDance.Mixfile do
  use Mix.Project

  def project do
    [app: :poll_dance,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison, :cowboy, :plug],
     mod: {PollDance, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.0.3"},
      {:plug, "~> 1.0.2"},
      {:poison, "~> 1.5"},
      {:httpoison, "~> 0.7.2"},
      {:pipe, "~> 0.0.2"},
      {:exactor, "~> 2.2"}
    ]
  end
end
