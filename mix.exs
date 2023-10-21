defmodule Propex.MixProject do
  use Mix.Project

  def project do
    [
      app: :propex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "An adaptation of PropEr for the Elixir world",
      deps: deps(),
      package: package(),
      docs: [
        main: "readme",
        extras: ["README.md"],
        assets: "assets",
      ],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      name: :propex,
      licenses: ["MIT"],
      maintainers: ["portasynthinca3"],
      links: %{
        "GitHub" => "https://github.com/portasynthinca3/propex/",
        "Docs" => "https://hexdocs.pm/propex",
      },
    ]
  end

  defp deps do
    [
      {:proper, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end
end
