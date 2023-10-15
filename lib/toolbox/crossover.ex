defmodule Toolbox.Crossover do
  alias Types.Chromosome

  @doc """
  Order one crossover, sometimes called "Davis order" crossover,
  is a crossover strategy well suited for ordered lists or permutations.
  It splices values from one parent, into the other parent to create the first
  child, and then repeats the process for child two. The splices ideally are
  different chunks of parents for each child, to prevent duplication issues.

  ## Example

  [5, 4, 0, 1, 3, 2, 6]
  [6, 3, 2, 5, 0, 4, 0]

  splicing 2..5 from parent one into parent two would result in the following
  child.

  [6, 3, 0, 1, 3, 2, 0]

  splicing 1..3 from parent two into parent one would result in the following
  child.

  [5, 3, 2, 5, 3, 2, 6]

  The random slice of `order_one/2` is not controllable. So we will just test
  that the size is maintained.

      iex> { c1, c2 } = Toolbox.Crossover.order_one(
      ...>   %Types.Chromosome{ genes: [5, 4, 0, 1, 3, 2, 5], size: 7 },
      ...>   %Types.Chromosome{ genes: [6, 3, 2, 5, 0, 4, 0], size: 7 }
      ...> )
      ...> { Enum.count(c1.genes), Enum.count(c2.genes) }
      { 7, 7 }
  """
  @spec order_one(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def order_one(p1, p2) do
    lim = Enum.count(p1.genes) - 1

    # get random range
    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    # p2 contribution
    slice1 = Enum.slice(p1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    p2_contrib = Enum.reject(p2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(p2_contrib, i1)

    # p1 contribution
    slice2 = Enum.slice(p2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    p1_contrib = Enum.reject(p1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(p1_contrib, i1)

    # make and return
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}

    {%Chromosome{
       genes: c1,
       size: p1.size
     },
     %Chromosome{
       genes: c2,
       size: p2.size
     }}
  end

  @spec single_point(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def single_point(c1 = %Chromosome{genes: []}, c2 = %Chromosome{genes: []}) do
    {c1, c2}
  end

  def single_point(p1, p2) do
    cx_point = :rand.uniform(p1.size)
    {p1_head, p1_tail} = Enum.split(p1.genes, cx_point)
    {p2_head, p2_tail} = Enum.split(p2.genes, cx_point)
    {c1, c2} = {p1_head ++ p2_tail, p2_head ++ p1_tail}

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  @spec uniform(Chromosome.t(), Chromosome.t(), float()) :: {Chromosome.t(), Chromosome.t()}
  def uniform(p1, p2, rate) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  @spec whole_arithmetic(Chromosome.t(), Chromosome.t(), float()) ::
          {Chromosome.t(), Chromosome.t()}
  def whole_arithmetic(p1, p2, alpha) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        {
          x * alpha + y * (1 - alpha),
          x * (1 - alpha) + y * alpha
        }
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end
end
