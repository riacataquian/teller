defmodule Teller.Supervisor do
  use GenServer
  import Wat

  def start_link do
    import Supervisor.Spec

    children = [
      worker(Teller, [], restart: :transient)
    ]

    {:ok, sup} = Supervisor.start_link(children, strategy: :simple_one_for_one, name: __MODULE__)

    puts "Starting Teller supervisor: #{inspect sup}", :magenta

    {:ok, sup}
  end
end
