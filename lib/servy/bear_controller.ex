defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.FileHandler
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView
  # alias Servy.FileHelper

  # defp render(conv, template, bindings \\ []) do
  #   content =
  #     template
  #     |> FileHelper.get_template_path()
  #     |> EEx.eval_file(bindings)

  #   %{conv | status: 200, resp_body: content}
  # end

  def index(%Conv{} = conv) do
    bears = Wildthings.list_bears() |> Enum.sort(&Bear.order_by_name_asc/2)
    # render(conv, "index.eex", bears: li_bears)
    %{conv | status: 200, resp_body: BearView.index(bears)}
  end

  def show(%Conv{} = conv, id) do
    bear = Wildthings.get_bear(id)
    %{conv | status: 200, resp_body: BearView.show(bear)}
  end

  def new(%Conv{} = conv) do
    FileHandler.handle_page_file("form.html", conv)
  end

  def create(%Conv{} = conv) do
    %{conv | status: 201, resp_body: "Created a #{conv.payload["type"]} bear named #{conv.payload["name"]}"}
  end
end
