defmodule ELogger.Plugs.RequestLoggerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  import Plug.Test

  alias ELogger.Plugs.RequestLogger

  doctest RequestLogger


  test "correctly logs requests" do
    conn = conn(:get, "/some/endpoint?param=1")
    opts = RequestLogger.init(section: :test)

    log_output = capture_log(fn ->
      conn = RequestLogger.call(conn, opts)

      assert conn.status == nil # Plug didn't halt or error
    end)

    assert log_output =~ "Request received"
  end
end
