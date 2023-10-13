defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """
  alias Types.Chromosome

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)

    for _ <- 1..population_size, do: genotype.()
  end

  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents =
      select_fn
      |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)

    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        {c1, c2} = apply(crossover_fn, [p1, p2])
        [c1, c2 | acc]
      end
    )
  end

  def mutation(population, opts \\ []) do
    mutate_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.scramble/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)

    n = floor(length(population) * rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(&apply(mutate_fn, [&1]))
  end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    population
    |> evolve(problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)

    statistics(population, generation, opts)

    # `evaluate` returns a sorted population, fittest first
    best = hd(population)

    fit_str =
      best.fitness
      |> :erlang.float_to_binary(decimals: 4)

    IO.write("\rCurrent Best: #{fit_str}\tGeneration: #{generation}")

    if problem.terminate?(population, generation) do
      IO.write("\nTermination generation: #{generation}")
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      parents_list = Enum.flat_map(parents, fn {p1, p2} -> [p1, p2] end)
      new_population = reinsertion(parents_list, offspring, leftover, opts)

      evolve(new_population, problem, generation + 1, opts)
    end
  end

  def statistics(population, generation, opts) do
    default_stats = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &Enum.sum(Enum.map(&1, fn c -> c.fitness end)) / Enum.count(&1)
    ]

    stats = Keyword.get(opts, :statistics, default_stats)

    stats_map =
      stats
      |> Enum.reduce(
        %{},
        fn {key, func}, acc ->
          Map.put(acc, key, func.(population))
        end
      )

    Utilities.Statistics.insert(generation, stats_map)
  end

  def reinsertion(parents, offspring, leftover, opts) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)

    apply(strategy, [parents, offspring, leftover])
  end
end
