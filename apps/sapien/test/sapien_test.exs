defmodule SapienTest do
  use ExUnit.Case
  doctest Sapien

  test "greets the world" do
    assert Sapien.hello() == :world
  end
end
