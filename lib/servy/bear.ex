defmodule Servy.Bear do
  @derive Jason.Encoder # Allow json encoding using Jason lib
  defstruct id: nil, name: "", type: "", hibernating: false

  def order_by_name_asc(%Servy.Bear{} = b1, %Servy.Bear{} = b2) do
    b1.name <= b2.name
  end
end
