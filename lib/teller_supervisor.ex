defmodule Teller.Supervisor do
  use GenServer
  import Wat

  def start do
    import Supervisor.Spec

    children = [
      worker(Teller, [], restart: :transient)
    ]

    {:ok, sup} = Supervisor.start_link(children, strategy: :simple_one_for_one, name: __MODULE__)

    puts "Starting Teller supervisor: #{inspect sup}", :magenta

    sup
  end
end
