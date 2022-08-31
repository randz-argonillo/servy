defmodule Servy.Api.BearController do
  alias Servy.Wildthings
  alias Servy.Conv

  def index(%Conv{} = conv) do
    encoded_bears = Jason.encode!(Wildthings.list_bears())

    %Conv{
      conv
      | status: 200,
        resp_body: encoded_bears,
        resp_headers: %{conv.resp_headers | "Content-Type" => "application/json"}
    }
  end

  def create(%Conv{} = conv) do
    resp_body_json = %{
      message: "Created a #{conv.payload["type"]} bear named #{conv.payload["name"]}!"
    }

    %Conv{conv | status: 201, resp_body: Jason.encode!(resp_body_json)} |> put_content_type()
  end

  def put_content_type(%Conv{} = conv) do
    updated_resp_headers = Map.put(conv.resp_headers, "Content-Type", "application/json")
    %Conv{conv | resp_headers: updated_resp_headers}
  end
end
