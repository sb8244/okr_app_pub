defmodule OkrAppWeb.EmailLayoutView do
  use OkrAppWeb, :view

  def display_date do
    {:ok, date} =
      Timex.now()
      |> Timex.format("%A, %B %d", Timex.Format.DateTime.Formatters.Strftime)

    date
  end
end
