defmodule Schedule do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..10, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10}
  end

  @impl true
  def fitness_function(chromosome) do
    schedule = chromosome.genes

    fitness =
      [schedule, difficulties(), usefulness(), interest()]
      |> Enum.zip()
      |> Enum.map(fn {class, dif, use, int} ->
        class * (0.3 * dif + 0.3 * use + 0.3 * int)
      end)
      |> Enum.sum()

    credit =
      schedule
      |> Enum.zip(credit_hours())
      |> Enum.map(fn {class, credits} -> class * credits end)
      |> Enum.sum()

    if credit > 18.0, do: -99999, else: fitness
  end

  defp credit_hours, do: [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  defp difficulties, do: [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  defp usefulness, do: [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  defp interest, do: [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]

  @impl true
  def terminate?(population, generation) do
    generation == 1000
  end
end

soln = Genetic.run(Schedule, crossover_type: &Toolbox.Crossover.single_point/2)

IO.write("\n")
IO.inspect(soln.genes)
IO.inspect(soln)
