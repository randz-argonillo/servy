defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [first_part, payload_line] =
      request
      |> String.split("\r\n\r\n")
      |> Enum.map(&String.trim/1)

    [request | header_lines] = String.split(first_part, "\r\n")
    [method, path, _] = String.split(request, " ")

    headers = parse_header_lines(header_lines)
    payload = parse_payload(headers["Content-Type"], payload_line)

    %Conv{
      method: method,
      status: nil,
      path: path,
      headers: headers,
      payload: payload,
      resp_body: ""
    }
  end

  def parse_header_lines(header_lines) when is_list(header_lines) do
    Enum.into(
      header_lines,
      %{},
      fn line ->
        [k, v] =
          line
          |> String.split(": ")
          |> Enum.map(&String.trim/1)

        {k, v}
      end
    )
  end

  @doc """
  Parses the given payload string of the form `key1=val1&key2=val2`

  ## Examples
    iex> payload = "name=Ollie&type=Bunny"
    iex> Servy.Parser.parse_payload("application/x-www-form-urlencoded", payload)
    %{"name" => "Ollie", "type" => "Bunny"}
    iex> Servy.Parser.parse_payload("multipart/form-data", payload)
    %{}
  """
  def parse_payload("application/x-www-form-urlencoded", payload) do
    URI.decode_query(payload)
  end

  def parse_payload("application/json", payload) do
    Jason.decode!(payload)
  end
  def parse_payload(_, _), do: %{}

end
