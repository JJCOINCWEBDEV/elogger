defmodule ELoggerTest do
  use ExUnit.Case, async: true
  doctest ELogger

  test "fetches current stacktrace" do
    assert {ELoggerTest, _, _, _} = ELogger.current_stacktrace() |> hd()
  end
end
