defmodule Servy.FileHandler do
  def handle_page_file(page_file, conv) do
    page_file
    |> get_page_path()
    |> File.read()
    |> handle_file(conv)
  end

  defp handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  defp handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error #{reason}"}
  end

  defp get_page_path(page_file) do
    "../../pages"
    |> Path.expand(__DIR__)
    |> Path.join(page_file)
  end
end
