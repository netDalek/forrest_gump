defmodule ForrestGumpTest do
  use ExUnit.Case
  doctest ForrestGump

  test "greets the world" do
    assert ForrestGump.hello() == :world
  end
end
