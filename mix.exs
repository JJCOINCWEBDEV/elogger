defmodule ELogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :elogger,
      version: "1.2.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:jason, "~> 1.4.5"},
      {:plug, "~> 1.20.3"},
      {:sentry, "~> 13.4.1"},
      {:finch, "~> 0.23.0"}
    ]
  end
end
