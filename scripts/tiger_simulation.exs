defmodule TigerSimulation do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..8, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 8}
  end

  @impl true
  def fitness_function(chromosome) do
    tropic_scores = [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
    tundra_scores = [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]
    traits = chromosome.genes

    traits
    |> Enum.zip(tundra_scores)
    |> Enum.map(fn {t, s} -> t * s end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(population, generation) do
    generation == 150
  end

  def average_tiger(population) do
    genes = Enum.map(population, & &1.genes)
    fitnesses = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_tigers = length(population)

    avg_fitness = Enum.sum(fitnesses) / num_tigers
    avg_age = Enum.sum(ages) / num_tigers

    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(&(Tuple.sum(&1) / num_tigers))

    %Chromosome{genes: avg_genes, fitness: avg_fitness, age: avg_age}
  end
end

tiger =
  Genetic.run(TigerSimulation,
    # this was 5 in ch10 of the book, but has to be 50 for
    # my algorithm to show similar gnuplots to the book
    population_size: 50,
    selection_rate: 0.9,
    mutation_rate: 0.1
    # statistics: %{average_tiger: &TigerSimulation.average_tiger/1}
  )

stats =
  :ets.tab2list(:statistics)
  |> Enum.map(fn {gen, stats} -> [gen, stats.mean_fitness] end)

{:ok, cmd} =
  Gnuplot.plot(
    [
      [:set, :title, "mean fitness versus generation"],
      [:plot, "-", :with, :points]
    ],
    [stats]
  )

# IO.write("\n")
# IO.inspect(tiger)
#
# genealogy = Utilities.Genealogy.get_tree()
# # IO.inspect(Graph.vertices(genealogy))
# {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
# {:ok, dotfile} = File.open("tiger_simulation.dot", [:write])
# :ok = IO.binwrite(dotfile, dot)
# :ok = File.close(dotfile)

# {_, zero_gen_stats} = Utilities.Statistics.lookup(0)
# {_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
# {_, thousandth_gen_stats} = Utilities.Statistics.lookup(1000)

# IO.inspect(zero_gen_stats.average_tiger)
# IO.inspect(fivehundred_gen_stats.average_tiger)
# IO.inspect(thousandth_gen_stats.average_tiger)

# IO.write("""
# 0th: #{zero_gen_stats.average_tiger}
# 500th: #{fivehundred_gen_stats.average_tiger}
# 1000th: #{thousandth_gen_stats.average_tiger}
# """)
