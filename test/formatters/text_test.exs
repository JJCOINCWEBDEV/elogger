defmodule ELogger.Formatters.TextTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ELogger.Formatters.Text

  doctest Text

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
    log_output = Text.format(level, @message, @timestamp, @metadata)

    assert log_output =~ @message
    assert log_output =~ "{\"key_a\":\":foo\",\"key_b\":\"123\"}"
    assert log_output =~ ELogger.Formatters.Helper.level_color(level)
  end
end
