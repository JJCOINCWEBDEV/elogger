defmodule ELogger.Formatters.JSONTest do
  use ExUnit.Case, async: true

  alias ELogger.Formatters.{JSON, Helper}

  doctest JSON

  @timestamp {{2026, 08, 06}, {01, 02, 03, 456}}
  @message "Some log message"
  @metadata [key_a: :foo, key_b: 123]

  test "correctly logs info level" do
    test_log(:info)
  end

  test "correctly logs warning level" do
    test_log(:warning)
  end

  test "correctly logs debug level" do
    test_log(:debug)
  end

  test "correctly logs error level" do
    test_log(:error)
  end

  defp test_log(level) do
    log_output = JSON.format(level, @message, @timestamp, @metadata)

    assert log_output =~ @message
    assert log_output =~ "{\"key_a\":\":foo\",\"key_b\":\"123\"}"
    assert log_output =~ Atom.to_string(level)

    assert {:ok, result} = Jason.decode(log_output)
    assert result["message"] == @message
    assert result["timestamp"] == Helper.timestamp(@timestamp)
    assert result["level"] == Atom.to_string(level)

    metadata =
      @metadata
      |> Enum.map(fn {k, v} ->
        {Atom.to_string(k), Helper.metadata_value(v)}
      end)
      |> Enum.into(%{})

    assert result["no_application"] == metadata
  end
end
