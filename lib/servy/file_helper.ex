defmodule Servy.FileHelper do
  @template_path Path.expand("../../templates", __DIR__)

  def get_template_path(file_name) do
    Path.join(@template_path, file_name)
  end
end
