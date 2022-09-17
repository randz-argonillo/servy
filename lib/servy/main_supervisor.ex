defmodule Servy.MainSupervisor do
  use Supervisor

  def start_link() do
    IO.puts("Starting MainSupervisor")
    Supervisor.start_link(__MODULE__, :ok, name: Servy.MainSupervisor)
  end

  @impl true
  def init(:ok) do
    children = [
      Servy.KickStarter,
      Servy.ServicesSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
