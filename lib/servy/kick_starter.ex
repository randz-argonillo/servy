defmodule Servy.KickStarter do
  use GenServer

  def start_link(_args) do
    IO.puts("Starting KickStarter")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Server callbacks
  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_http_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer crashes: #{reason}")
    server_pid = start_http_server()
    {:noreply, server_pid}
  end

  defp start_http_server() do
    IO.puts("Starting HttpServer process...")

    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port]) # this links the HttpServer process with KickStarter process
    Process.register(server_pid, :http_server)
    server_pid
  end
end
