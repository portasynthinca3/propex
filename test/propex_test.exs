defmodule PropexTest do
  use ExUnit.Case
  use PropEx

  alias PropEx.Test.{Arithmetics, Strings}

  describe "Arithmetics.add/2" do
    test "performs addition" do
      assert Arithmetics.add(1, 3) == 4
      assert Arithmetics.add(10, -3) == 7
      assert Arithmetics.add(-10, -3) == -13
      assert Arithmetics.add(-10, 3) == -7
    end
  end

  describe "PropEx" do
    test "tests inline addition" do
      forall [a :: integer(), b :: integer()] do
        a + b - b == a &&
        a + b - a == b
      end
    end

    test "tests Arithmetics.add/2 manually" do
      forall [a :: integer(), b :: integer()] do
        Arithmetics.add(a, b) - b == a &&
        Arithmetics.add(a, b) - a == b
      end
    end

    test "tests Arithmetics.add/2 automatically" do
      forall arguments_of Arithmetics.add/2 do
        result - b == a &&
        result - a == b
      end
    end

    test "tests Strings.concat/2 automatically" do
      forall arguments_of Strings.concat/2 do
        result == "#{a}#{b}"
      end
    end
  end
end
