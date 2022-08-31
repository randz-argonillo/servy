defmodule Servy.Plugins do
  alias Servy.Conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def track_unknown(%Conv{status: 404} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning a page is not found #{conv.path}")
    end

    conv
  end

  def track_unknown(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end

  def put_content_length(%Conv{} = conv) do
    updated_resp_headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))

    %Conv{conv | resp_headers: updated_resp_headers}
  end
end
