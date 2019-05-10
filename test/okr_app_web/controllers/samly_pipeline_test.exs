defmodule OkrAppWeb.SamlyPipelineTest do
  use ExUnit.Case, async: true
  use Plug.Test
  use Mockery

  alias OkrAppWeb.SamlyPipeline

  test "the request is halted with an error if there is no user" do
    mock(OkrApp.Users, :get_active_user, {:error, :user_not_found})

    conn =
      conn(:get, "/foo")
      |> put_private(:samly_assertion, get_assertion("test"))
      |> SamlyPipeline.call(%{})

    assert conn.status == 401
    assert conn.halted
    assert conn.resp_body == "You do not have an account setup. Please contact helpdesk@salesloft.com to be setup."
  end

  test "the request is not modified if there is an active user" do
    mock(OkrApp.Users, :get_active_user, {:ok, "_"})

    original_conn =
      conn(:get, "/foo")
      |> put_private(:samly_assertion, get_assertion("test"))

    conn =
      original_conn
      |> SamlyPipeline.call(%{})

    assert conn == original_conn
  end

  defp get_assertion(user_name),
    do: %Samly.Assertion{
      attributes: %{
        "email_address" => "steve.bussey+dev@salesloft.com",
        "first_name" => "Stephen",
        "last_name" => "Bussey"
      },
      authn: %{
        "authn_context" => "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
        "authn_instant" => "2018-08-13T04:04:59.443Z",
        "session_index" => "id153413308486489584637"
      },
      computed: %{},
      conditions: %{
        "audience" => "http://www.okta.com/exkfwa8zygLeSLHtA0h7",
        "not_before" => "2018-08-13T03:59:59.874Z",
        "not_on_or_after" => "2018-08-13T04:09:59.874Z"
      },
      idp_id: "",
      issue_instant: "2018-08-13T04:04:59.874Z",
      issuer: "http://www.okta.com/exkfwa8zygLeSLHtA0h7",
      recipient: "https://localhost.salesloft.com:6007/sso/sp/consume/okta",
      subject: %Samly.Subject{
        confirmation_method: :bearer,
        in_response_to: "id153413308486489584637",
        name: user_name,
        name_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified",
        name_qualifier: :undefined,
        notonorafter: "2018-08-13T04:09:59.874Z",
        sp_name_qualifier: :undefined
      },
      version: "2.0"
    }
end
