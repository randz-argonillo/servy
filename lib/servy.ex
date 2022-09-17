defmodule Servy do
  use Application

  def start(_type, _args) do
    IO.puts("Starting Servy application")
    Servy.MainSupervisor.start_link()
  end
end

# IO.puts Servy.hello("Randy")
