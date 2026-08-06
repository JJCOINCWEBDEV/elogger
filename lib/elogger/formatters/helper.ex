defmodule ELogger.Formatters.Helper do
  def metadata_value(value) do
    case value do
      %{__struct__: Ecto.Association.NotLoaded} ->
        :not_loaded

      %{__struct__: struct} ->
        convert_if_no_encoder(value, fn value ->
          Map.from_struct(value)
          |> Enum.map(fn {k, v} -> {k, metadata_value(v)} end)
          |> Enum.into(%{})
          |> Map.put(:__source_struct, struct)
        end)

      map when is_map(map) ->
        Enum.map(value, fn {k, v} -> {k, metadata_value(v)} end) |> Enum.into(%{})

      tuple when is_tuple(tuple) ->
        case :inet.ntoa(tuple) do
          {:error, _} -> %{tuple: value |> Tuple.to_list() |> Enum.map(&metadata_value/1)}
          parsed_ip -> to_string(parsed_ip)
        end

      list when is_list(list) ->
        Enum.map(list, &metadata_value/1)

      binary when is_binary(binary) ->
        prune_binary(binary)

      _else ->
        convert_if_no_encoder(value, &inspect/1)
    end
  end

  def timestamp(timestamp) do
    {{year, month, day}, {hour, minute, second, millisecond}} = timestamp

    case NaiveDateTime.new(year, month, day, hour, minute, second, millisecond * 1000) do
      {:ok, naive_date_time} ->
        naive_date_time
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_iso8601()

      {:error, error} ->
        Sentry.capture_message("Invalid Timestamp #{inspect(timestamp)}, reason: #{error}", stacktrace: ELogger.current_stacktrace())
        DateTime.to_iso8601(DateTime.utc_now())
    end
  end

  def level_color(level) do
    case level do
      :info -> IO.ANSI.green()
      :error -> IO.ANSI.red()
      :debug -> IO.ANSI.light_blue()
      :warning -> IO.ANSI.yellow()
      _ -> IO.ANSI.white()
    end
  end

  defp convert_if_no_encoder(value, _converter) when value in [nil, true, false] do
    value
  end

  defp convert_if_no_encoder(value, converter) do
    case Jason.Encoder.impl_for(value) do
      encoder when encoder in [Jason.Encoder.Atom, Jason.Encoder.Integer, Jason.Encoder.Float, Jason.Encoder.Any] ->
        converter.(value)

      _else ->
        value
    end
  end

  @replacement "�"
  # replaces all non-utf8 characters in binary with replacement
  def prune_binary(binary) when is_binary(binary), do: prune_binary(binary, <<>>)
  def prune_binary(<<h::utf8, t::binary>>, acc), do: prune_binary(t, <<acc::binary, h::utf8>>)
  def prune_binary(<<_, t::binary>>, acc), do: prune_binary(t, <<acc::binary, @replacement>>)
  def prune_binary(<<>>, acc), do: acc
end
