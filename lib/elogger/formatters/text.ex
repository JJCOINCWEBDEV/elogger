defmodule ELogger.Formatters.Text do
  alias ELogger.Formatters.Helper

  def format(level, message, timestamp, metadata) do
    timestamp = Helper.timestamp(timestamp)
    message = message |> :erlang.iolist_to_binary() |> Helper.prune_binary()

    encoded_metadata =
      metadata
      |> Enum.filter(fn {k, _v} ->
        k != :pid
      end)
      |> Enum.map(fn {k, v} ->
        {k, Helper.metadata_value(v)}
      end)
      |> Enum.into(%{})

    level_color = Helper.level_color(level)

    text =
      [
        level_color,
        Atom.to_string(level) |> String.upcase() |> String.pad_trailing(5, " "),
        IO.ANSI.reset(),
        IO.ANSI.light_cyan(),
        timestamp |> String.pad_trailing(27, " "),
        IO.ANSI.reset(),
        level_color,
        encoded_metadata[:application] || "no_application",
        IO.ANSI.reset(),
        "\n",
        apply(IO.ANSI, metadata[:ansi_color] || :white, []),
        message,
        IO.ANSI.reset(),
        "\n",
        IO.ANSI.light_magenta(),
        Poison.encode!(encoded_metadata),
        IO.ANSI.reset()
      ]
      |> Enum.join(" ")

    text <> "\n\n"
  end
end
