defmodule EloggerTest do
  use ExUnit.Case
  doctest Elogger

  test "greets the world" do
    assert Elogger.hello() == :world
  end
end
