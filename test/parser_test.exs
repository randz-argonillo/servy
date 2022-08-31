defmodule ParserTest do
  use ExUnit.Case
  alias Servy.Parser

  doctest Servy.Parser


  test "parses a list of header fields into a map" do
    headers_map = Parser.parse_header_lines(["a: 1", "b:2"])
    assert headers_map == %{"a" => "1", "b" => "2"}
  end
end
