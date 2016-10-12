defmodule BankQueue do
  use GenServer
  import Wat

  def wat do
    BankQueue.start

    for _n <- 1..10, do: BankQueue.start_tellers

    BankQueue.push 1..1000
  end

  def start(queue  \\ 1..5) do
    TV.Supervisor.start(queue)
  end

  # TODO: Spawn list of tellers
  def start_tellers do
    case Process.whereis(Teller.Supervisor) do
      nil ->
        Teller.Supervisor.start
        |> start_new_teller
      sup ->
        start_new_teller(sup)
    end
  end

  def connect_to(node_name) when is_binary(node_name) do
    Node.connect :"#{node_name}@Rias-MBP"
  end

  def connect_to(_node_name) do
    raise "Node name must be a string"
  end

  def get_queue do
    GenServer.call({:global, :tv}, :get_queue)
  end

  def push(queue) do
    GenServer.cast({:global, :tv}, {:push, queue |> Enum.to_list})
    get_queue
  end

  defp start_new_teller(sup) do
    Supervisor.start_child(sup, [])
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
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
   GenServer.cast({:global, :tv}, {:ask, self}) 

   {:ok, state}
  end

  def handle_cast({:receive_job, []}, _state) do
    Process.sleep(250)

    puts "Process: #{inspect self} --------- Done: :empty", :cyan

    GenServer.cast({:global, :tv}, {:ask, self}) 

    {:noreply, []}
  end

  def handle_cast({:receive_job, job}, state) do
    [10, 500, 1000]
    |> Enum.shuffle
    |> Enum.take(1)
    |> hd
    |> Process.sleep

    color = 
      [:cyan, :yellow, :green]
      |> Enum.shuffle
      |> Enum.take(1)
      |> hd

    puts "Process: #{inspect self} --------- Done: #{inspect job}", color
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
