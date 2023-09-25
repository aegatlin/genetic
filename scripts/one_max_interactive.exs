defmodule OneMax do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..42, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 42}
  end

  @impl true
  def fitness_function(chromosome) do
    IO.inspect(chromosome)
    fit = IO.gets("Rate from 1 to 10 \n")
    IO.inspect(fit)
    String.to_integer(fit)
  end

  @impl true
  def terminate?([best | _]), do: best.fitness == 42
end

solution = Genetic.run(OneMax)

IO.write("\n")
IO.inspect(solution)
