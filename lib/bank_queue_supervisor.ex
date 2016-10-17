defmodule BankQueue.Supervisor do
  use GenServer
  import Wat

  def start(queue) do
    import Supervisor.Spec

    children = [
      supervisor(TV.Supervisor, [queue]),
      supervisor(Teller.Supervisor, [])
    ]

    {:ok, sup} = Supervisor.start_link(children, strategy: :rest_for_one, name: __MODULE__)

    puts "Starting BankQueue supervisor: #{inspect sup}", :magenta

    sup
  end
end
