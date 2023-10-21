# PropEx
![shitpost-y logo](./logo.png)\
<sup>~~I swear this is not a shitpost~~</sup>

An adaptation of PropEr for the Elixir world. As of right now, this is a
prototype. Feel free to open issues and send pull requests!

## Installation
Add the library as a dependency for the `test` environment
```elixir
defp deps do
  [
    {:propex, "~> 0.1", only: test}
  ]
end
```

## Usage
Suppose that you want to test the following module:
```elixir
# lib/my_lib.ex
defmodule MyLib do
  @spec add(a :: integer(), b :: integer()) :: integer()
  def add(a, b), do: a + b
end
```

### Automatic
You can automatically generate the argument list assuming that you had written
a `@spec` for your function:
```elixir
# test/my_lib_test.exs
defmodule MyLibTest do
  use ExUnit.Case
  use PropEx

  test "add/2" do
    forall arguments_of MyLib.add/2 do
      # a, b and result are assigned automatically
      result - a == b &&
      result - b == a
    end
  end
end
```

### Manual
You can specify the variables and types yourself if you want to
```elixir
# test/my_lib_test.exs
defmodule MyLibTest do
  use ExUnit.Case
  use PropEx

  test "add/2" do
    forall [a :: integer(), b :: integer()] do
      MyLib.add(a, b) == a + b
    end
  end
end
```
