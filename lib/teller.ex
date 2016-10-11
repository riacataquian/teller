defmodule BankQueue do
  use GenServer
  import Wat

  def start(queue  \\ 1..5) do
    TV.Supervisor.start(queue)
  end


  def start_tellers do
    Teller.start_link
  end

  def get_queue do
    GenServer.call({:global, :tv}, :get_queue)
  end

  def push(queue) do
    GenServer.cast({:global, :tv}, {:push, queue |> Enum.to_list})
    get_queue
  end

end

defmodule Teller do
  use GenServer
  import Wat

  @doc """
  1. Ask Job
  2. Receive Job
  3. Perform Job
  """

  def start_link do
    for _ <- 1..3 do
      GenServer.start_link(__MODULE__, [])
    end
  end

  def init(state) do
   GenServer.cast({:global, :tv}, {:ask, self}) 

   {:ok, state}
  end

  def handle_cast({:receive_job, []}, _state) do
    Process.sleep(500)

    puts "Received: :waiting --------- Process: #{inspect self}", :cyan

    puts "Simulating server shutdown.."

    GenServer.stop({:global, :tv}, :brutal_kill)
    GenServer.cast({:global, :tv}, {:ask, self}) 

    {:noreply, []}
  end

  def handle_cast({:receive_job, job}, state) do
    Process.sleep(500)

    puts "Received: #{job} --------- Process: #{inspect self}", :cyan
    GenServer.cast({:global, :tv}, {:ask, self}) 

    {:noreply, state}
  end
end

defmodule TV do
  use GenServer
  import Wat

  @doc """
  1. Receive demand
  2. Send ng job
  """

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue |> Enum.to_list, name: {:global, :tv})
  end

  def handle_call(:get_queue, _from, state) do
    puts "Current queue size: #{inspect length(state)}", :green

    {:reply, state, state}
  end

  def handle_cast({:push, items}, state) do
    new_state = state ++ items

    puts "Pushing new items on TV: #{inspect new_state}", :cyan

    {:noreply, new_state}
  end

  def handle_cast({:ask, sender}, []) do
    GenServer.cast(sender, {:receive_job, []})

    puts "Sender: #{inspect sender} --------- Job: empty", :red

    {:noreply, []} 
  end

  def handle_cast({:ask, sender}, [head | tail]) do
    GenServer.cast(sender, {:receive_job, head})

    puts "Sender: #{inspect sender} --------- Job: #{head}", :cyan

    {:noreply, tail} 
  end
end
