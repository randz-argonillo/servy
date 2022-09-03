defmodule Servy.Fetcher do

  def async(fun) do
    parent = self()
    spawn(fn -> send(parent, {:result, self(), fun.()}) end)
  end

  def get_result(pid) do
    receive do
      {:result, ^pid, value} -> value
    end
  end
end
