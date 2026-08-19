defmodule ELogger.Plugs.RequestLogger do
  @moduledoc """
  A plug for logging basic request information in the format.
  Based on Plug.Logger.
  """

  require Logger
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :log, :info), Keyword.fetch!(opts, :section)}
  end

  def call(conn, {level, section}) do
    Logger.metadata(section: section)

    Logger.log(level, fn ->
      {"Request received",
       method: conn.method, request_path: conn.request_path, remote_ip: conn.remote_ip, params: conn.params, body_params: conn.body_params}
    end)

    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      Logger.log(level, fn ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :microsecond)

        {"Response ready", connection_type: connection_type(conn), status: conn.status, duration: diff / 1000.0, resp_body: conn.resp_body}
      end)

      conn
    end)
  end

  defp connection_type(%{state: :set_chunked}), do: :chunked
  defp connection_type(_), do: :sent
end
