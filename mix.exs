defmodule GracefulGenserver.MixProject do
  use Mix.Project

  def project do
    [
      app: :graceful_genserver,
      version: "0.1.3",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Graceful GenServer",
      source_url: "https://github.com/salseeg/graceful-genserver",
      package: package(),
      description:
        "GenServer wrapper with graceful termination capabilities, tailored for use in supervision tree-based scenarios"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/salseeg/graceful-genserver"}
    ]
  end
end
