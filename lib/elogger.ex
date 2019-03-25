defmodule Elogger do
  @moduledoc """
  Documentation for Elogger.
  """

  def current_stacktrace do
    {:current_stacktrace, stacktrace} = Process.info(self(), :current_stacktrace)
    Enum.slice(stacktrace, 2..-1)
  end
end
