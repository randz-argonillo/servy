defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_args) do
    IO.puts("Starting ServicesSupervisor")
    Supervisor.start_link(__MODULE__, :ok, name: :services_supervisor0)
  end

  def init(:ok) do
    children = [
      Servy.SensorServer,
      Servy.PledgeServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
