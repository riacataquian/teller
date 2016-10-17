defmodule TV.Supervisor do
  use GenServer
  import Wat

  def start_link(queue \\ 1..5) do
    import Supervisor.Spec

    # TODO: Supervise tv and teller
    children = [
      worker(TV, [queue], name: TV)
    ]
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)

    puts "Starting TV supervisor: #{inspect pid}", :magenta

    {:ok, pid}
  end
end
