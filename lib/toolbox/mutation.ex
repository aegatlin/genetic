defmodule Toolbox.Mutation do
  alias Types.Chromosome
  use Bitwise

  def flip(chromosome), do: flip(chromosome, 0.5)

  def flip(chromosome, p) do
    genes =
      chromosome.genes
      |> Enum.map(fn g ->
        if :rand.uniform() < p do
          g ^^^ 1
        else
          g
        end
      end)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def gaussian(chromosome) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)

    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))

    genes =
      chromosome.genes
      |> Enum.map(fn _ -> :rand.normal(mu, sigma) end)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  # additional mutations that can be implemented
  # Swap: swap random pairs of genes
  # Uniform: replace genes with uniform random numbers
  # Invert: invert the order of the chromosome
end
