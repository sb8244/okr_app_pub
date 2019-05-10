defmodule Scim.Web.Plug do
  def init(opts) do
    if Keyword.get(opts, :behavior) == nil do
      raise "#{__MODULE__} must be forwarded to with behavior"
    end

    opts
  end

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:behavior, Keyword.fetch!(opts, :behavior))
    |> Scim.Web.Router.call(opts)
  end
end
