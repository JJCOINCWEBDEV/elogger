defmodule ELogger.Formatters.JSON do
  alias ELogger.Formatters.Helper

  def format(level, message, timestamp, metadata) do
    timestamp = Helper.timestamp(timestamp)
    message = message |> :erlang.iolist_to_binary() |> Helper.prune_binary()
    main_data = %{message: message, level: level, timestamp: timestamp}
    base_key = metadata[:section] || metadata[:application] || "no_application"

    metadata =
      metadata
      |> Enum.filter(fn {k, _v} ->
        k != :pid
      end)
      |> Enum.map(fn {k, v} ->
        {k, Helper.metadata_value(v)}
      end)
      |> Enum.into(%{})

    data =
      Map.new(%{base_key => metadata})
      |> Map.merge(main_data)

    json =
      with {:ok, json} <- Poison.encode(data) do
        json
      else
        {:error, error} ->
          Sentry.capture_message(inspect(error), stacktrace: ELogger.current_stacktrace())
          %{message: "Internal logger error, please see sentry for details", level: :error} |> Poison.encode!()
      end

    json <> "\n"
  end
end
