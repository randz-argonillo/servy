defmodule Servy.GenericServer do
  def start(server_name, initial_state, cb_module) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, cb_module])
    Process.register(pid, server_name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, cb_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = cb_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, cb_module)

      {:cast, message} ->
        new_state = cb_module.handle_cast(message, state)
        listen_loop(new_state, cb_module)

      unknown_message ->
        IO.puts("Unknown message #{inspect(unknown_message)}")
        listen_loop(state, cb_module)
    end
  end
end

defmodule Servy.PledgeServer do
  use GenServer
  @server_name :pledge_server

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client
  def start() do
    GenServer.start(__MODULE__, %State{}, name: @server_name)
  end

  def init(%State{} = state) do
    {:ok, %State{state | pledges: fetch_recent_pledges()}}
  end

  @doc """
  Returns recent pledges
  """
  def recent_pledges() do
    # self() here is the client pid since this function will be called in the client
    GenServer.call(@server_name, :recent_pledges)
  end

  def create_pledge(name, amount) do
    GenServer.call(@server_name, {:create_pledge, name, amount})
  end

  def clear() do
    GenServer.cast(@server_name, :clear)
  end

  def increase_cache(size) do
    GenServer.cast(@server_name, {:increase_cache, size})
  end

  defp send_pledge_to_service(_name, _amount) do
    # Send pledge to external service

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  def fetch_recent_pledges() do
    [{"wilma", 20, "mark", 30}]
  end

  # Server

  def handle_call({:create_pledge, name, amount}, _from, %State{} = state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    pledges = [{name, amount} | recent_pledges]

    {:reply, id, %State{state | pledges: pledges}}
  end

  def handle_call(:recent_pledges, _from, %State{} = state) do
    {:reply, state.pledges, state}
  end

  def handle_cast(:clear, %State{} = state) do
    {:noreply, %State{state | pledges: []}}
  end

  def handle_cast({:increase_cache, size}, %State{} = state) do
    {:noreply, %State{state | cache_size: size}}
  end
end
