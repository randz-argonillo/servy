defmodule Servy.PledgeController do
  alias Servy.Conv
  alias Servy.PledgeServer

  def index(%Conv{} = conv) do
    pledges = PledgeServer.recent_pledges()
    %Conv{conv | status: 200, resp_body: (inspect pledges)}
  end

  def create(%Conv{} = conv, %{"name" => name, "amount" => amount}) do
    PledgeServer.create_pledge(name, String.to_integer(amount))
    %Conv{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

end
