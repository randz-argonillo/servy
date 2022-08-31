defmodule Servy.BearView do
  require EEx
  alias Servy.FileHelper

  EEx.function_from_file(:def, :index, FileHelper.get_template_path("index.eex"), [:bears])
  EEx.function_from_file(:def, :show, FileHelper.get_template_path("show.eex"), [:bear])

end
