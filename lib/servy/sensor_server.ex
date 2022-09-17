defmodule Servy.SensorServer do
  use GenServer

  alias Servy.Tracker
  alias Servy.VideoCam

  @server_name :sensor_server

  defmodule State do
    defstruct sensor_data: nil, refresh_interval: :timer.minutes(60)
  end


  # Server
  def init(%State{} = state) do
    schedule_refetch_data(state.refresh_interval)
    sensors_data = fetch_sensors_data()
    {:ok, %State{state | sensor_data: sensors_data}}
  end

  def handle_info(:refetch, %State{} = state) do
    sensors_data = fetch_sensors_data()

    schedule_refetch_data(state.refresh_interval)
    {:noreply, %State{state | sensor_data: sensors_data}}
  end

  def handle_info(unexpected, state) do
    IO.puts "Can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  def handle_call(:get_sensors_data, _from, %State{} = state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast({:set_refresh_interval, milleseconds}, %State{} = state) do
    new_state = %State{state | refresh_interval: milleseconds}
    {:noreply, new_state}
  end

  defp schedule_refetch_data(interval) do
    Process.send_after(self(), :refetch, interval)
  end

  # Client
  def start_link(_opts) do
    IO.puts("Starting SensorServer")
    GenServer.start_link(__MODULE__, %State{}, name: @server_name)
  end

  def get_sensors_data() do
    GenServer.call(@server_name, :get_sensors_data)
  end

  def set_refresh_interval(milliseconds) do
    GenServer.cast(@server_name, {:set_refresh_interval, milliseconds})
  end

  defp fetch_sensors_data() do
    get_loc_task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots =
      [
        "camera-1",
        "camera-2",
        "camera-3",
        "camera-4",
        "camera-5",
        "camera-6",
        "camera-7",
        "camera-8",
        "camera-9",
        "camera-10"
      ]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(fn task ->
        case Task.yield(task, :timer.seconds(5)) do
          {:ok, result} ->
            result

          nil ->
            Task.shutdown(task)
        end
      end)

    where_is_bigfoot = Task.await(get_loc_task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
