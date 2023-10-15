defmodule Genetic.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      # ch 11 using nifs to optimize
      # compilers: [:genetic] ++ Mix.compilers,
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Genetic.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # TODO: update to 0.16.0, it's modern version
      # this version is used in the book
      {:libgraph, "~> 0.13.0"},
      {:gnuplot, "~> 1.19"},
      # commented out because it doesn't work
      # {:alex, "~> 0.3.2"},
      {:benchee, "~> 1.0.1"},
      {:exprof, "~> 0.2.0"},
      {:stream_data, "~> 0.5", only: :test},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

# ch 11 using NIFs to optimize
# defmodule Mix.Tasks.Compile.Genetic do
#   use Mix.Task.Compiler
#
#   def run(_args) do
#     {result, _errcode} =
#       System.cmd(
#         "gcc",
#         ["-fpic", "-shared", "-o", "genetic.so", "src/genetic.c"],
#         stderr_to_stdout: true
#       )
#
#     IO.puts(result)
#   end
# end
