defmodule TV.Supervisor do
  use GenServer
  import Wat

  def start(queue \\ 1..5) do
    import Supervisor.Spec

    children = [
      worker(TV, [queue], name: TV)
    ]

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one, max_restarts: 199)

    puts "Starting supervisor: #{inspect pid}", :magenta
  end
end
