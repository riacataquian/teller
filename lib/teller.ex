defmodule Teller do
  use GenServer
  require Logger

  @doc """
  1. Ask Job
  2. Receive Job
  3. Perform Job
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
   GenServer.cast(:tv, {:ask, self}) 

   {:ok, state}
  end

  def handle_cast({:receive_job, []}, _state) do
    Process.sleep(500)

    Logger.info "Received: :waiting --------- Process: #{inspect self}"
    GenServer.cast(:tv, {:ask, self}) 

    {:noreply, []}
  end

  def handle_cast({:receive_job, job}, state) do
    Process.sleep(500)

    Logger.info "Received: #{job} --------- Process: #{inspect self}"
    GenServer.cast(:tv, {:ask, self}) 

    {:noreply, state}
  end
end

defmodule TV do
  require Logger
  use GenServer

  @doc """
  1. Receive demand
  2. Send ng job
  """

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue |> Enum.to_list, name: :tv)
  end

  def init(state) do
    Teller.start_link

    {:ok, state}
  end

  def push(queue) do
    GenServer.cast(:tv, {:push, queue |> Enum.to_list})
  end

  def handle_cast({:push, items}, state) do
    new_state = state ++ items

    Logger.warn "Pushing new items on TV: #{inspect new_state}"

    {:noreply, new_state}
  end

  def handle_cast({:ask, sender}, []) do
    GenServer.cast(sender, {:receive_job, []})

    Logger.error "Sender: #{inspect sender} --------- Job: empty"

    {:noreply, []} 
  end

  def handle_cast({:ask, sender}, [head | tail]) do
    GenServer.cast(sender, {:receive_job, head})

    Logger.warn "Sender: #{inspect sender} --------- Job: #{head}"

    {:noreply, tail} 
  end
end
