defmodule Teller.Supervisor do
  use GenServer

  def start do
    import Supervisor.Spec

    children = [
      worker(TV, [1..5], name: TV)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, max_restarts: 100)
  end
end
