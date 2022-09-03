defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.FileHandler
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView
  alias Servy.VideoCam
  alias Servy.Tracker
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
    %{
      conv
      | status: 201,
        resp_body: "Created a #{conv.payload["type"]} bear named #{conv.payload["name"]}"
    }
  end

  def get_sensors(%Conv{} = conv) do
    # parent = self()

    # for n <- 1..3 do
    #   spawn(fn ->
    #     snapshot = VideoCam.get_snapshot("camera-#{n}")
    #     send(parent, {:result, snapshot})
    #   end)
    # end

    # snapshots =
    #   for _ <- 1..3 do
    #     receive do
    #       {:result, snapshot} ->
    #         snapshot
    #     end
    #   end

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

    %Conv{conv | status: 200, resp_body: inspect({where_is_bigfoot, snapshots})}
  end
end

# t = case Task.yield(nil)
#       {:ok, result} ->
#         result
#       nil ->
#         Task.shutdown(task)
#     end

# t = case Task.yield(task, 5000) do
#   {:ok, result} ->
#     result
#   nil ->
#     Logger.warn "Timed out!"
#     Task.shutdown(task)
# end
