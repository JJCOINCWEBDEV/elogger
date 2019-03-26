defmodule ELoggerTest do
  use ExUnit.Case
  doctest ELogger

  test "greets the world" do
    assert ELogger.hello() == :world
  end
end
