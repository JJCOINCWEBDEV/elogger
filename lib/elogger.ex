defmodule ELogger do
  @moduledoc """
  Documentation for ELogger.
  """

  def current_stacktrace do
    {:current_stacktrace, stacktrace} = Process.info(self(), :current_stacktrace)
    Enum.slice(stacktrace, 2..-1)
  end
end
