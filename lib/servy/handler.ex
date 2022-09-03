defmodule Servy.Handler do
  alias Servy.Plugins
  alias Servy.Parser
  alias Servy.FileHandler
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api.BearController, as: ApiBearController

  def handle(request) do
    request
    |> Parser.parse()
    # |> Plugins.log()
    |> Plugins.rewrite_path()
    |> route()
    |> Plugins.track_unknown()
    |> Plugins.put_content_length()
    |> format()
  end

  def route(%Conv{method: "GET", path: "/kaboom"}) do
    raise 'Kaboom!'
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    BearController.get_sensors(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    BearController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    BearController.show(conv, id)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    ApiBearController.create(conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    FileHandler.handle_page_file("about.html", conv)
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time
    |> String.to_integer()
    |> :timer.sleep()

    %Conv{conv | status: 200, resp_body: "I'm awake!"}
  end

  def route(%Conv{method: method, path: path} = conv) do
    %{conv | status: 404, resp_body: "Not found path #{path} for method #{method}"}
  end

  def format(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end

# request = """
# GET /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: ChromeBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /birds HTTP/1.1
# Host: example.com
# User-Agent: ChromeBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# # request = """
# # GET /wildlife HTTP/1.1
# # Host: example.com
# # User-Agent: ChromeBrowser/1.0
# # Accept: */*

# # """

# # response = Servy.Handler.handle(request)
# # IO.puts(response)

# request = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ChromeBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /bears/new HTTP/1.1
# Host: example.com
# User-Agent: ChromeBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# POST /bears HTTP/1.1
# Host: example.com
# User-Agent: ChromeBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-urlencoded
# Content-Length: 21

# name=Baloo&type=Brown
# """

# response = Servy.Handler.handle(request)
# IO.puts(response)
