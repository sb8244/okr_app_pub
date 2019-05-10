defmodule OkrApp.Mailer.Overview do
  use Bamboo.Phoenix, view: OkrAppWeb.EmailView

  alias OkrApp.Mailer.{OverviewState, Recipient}

  def generate(%OverviewState{
        cycle_title: cycle_title,
        loaded_objectives: objectives,
        recipient: %Recipient{to: to_address, first_name: name, slug: slug, type: :user}
      }) do
    {template, subject} =
      if objectives == [] do
        {:no_objectives, "It's time to define your OKRs"}
      else
        {:overview, "It's time to review your OKRs"}
      end

    new_email()
    |> to(to_address)
    |> from({"SalesLoft OKRs", "okr-noreply@salesloft.com"})
    |> put_header("reply-to", "okrs@salesloft.com")
    |> subject(subject)
    |> assign(:first_name, name)
    |> assign(:cycle_title, cycle_title)
    |> assign(:objectives, objectives)
    |> assign(:view_url, "https://okrs.salesloft.com/#{slug}")
    |> put_html_layout({OkrAppWeb.EmailLayoutView, "email.html"})
    |> render(template)
    |> premail()
  end

  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)

    email
    |> html_body(html)
  end
end
