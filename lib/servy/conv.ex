defmodule Servy.Conv do
  defstruct method: "",
            status: nil,
            path: "",
            headers: "",
            payload: "",
            resp_body: "",
            resp_headers: %{"Content-Type" => "text/html", "Content-Length" => 0}

  def full_status(%Servy.Conv{} = conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(status_code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[status_code]
  end
end
