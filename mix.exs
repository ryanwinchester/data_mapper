defmodule DataMapper.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_mapper,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_file: {:no_warn, "priv/plts/dialyzer.plt"}],

      name: "MyApp",
      source_url: "https://github.com/ryanwinchester/data_mapper",
      homepage_url: "https://github.com/ryanwinchester/data_mapper",
      docs: [
        main: "DataMapper",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ],

      package: package()
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
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "A macro module and behaviour with default mapping implementations.",
      licenses: ["Apache v2.0"],
      links: %{
        "github" => "https://github.com/ryanwinchester/data_mapper",
        "company" => "https://sevenshores.co"
      }
    ]
  end
end
