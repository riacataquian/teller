defmodule Wat do
  def puts(message, color \\ :red) do
    IO.puts IO.ANSI.format [color, message]
  end
end
