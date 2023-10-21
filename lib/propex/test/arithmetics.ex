defmodule PropEx.Test.Arithmetics do
  @spec add(a :: integer(), b :: integer()) :: integer()
  def add(a, b), do: a + b

  @spec sub(a :: integer(), b :: integer()) :: integer()
  def sub(a, b), do: a - b
end
