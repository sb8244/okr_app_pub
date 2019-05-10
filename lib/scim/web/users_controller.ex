defmodule Scim.Web.UsersController do
  use Phoenix.Controller

  @list_schemas ["urn:ietf:params:scim:api:messages:2.0:ListResponse"]

  # https://developer.okta.com/standards/SCIM/#read-list-of-accounts-with-search-get-users
  # https://developer.okta.com/standards/SCIM/#filtering-on-username-eq-required
  # https://developer.okta.com/standards/SCIM/#resource-paging
  def index(conn = %{assigns: %{behavior: scim_behavior}}, params) do
    items_per_page = Map.get(params, "count", "25") |> String.to_integer()
    start_index = Map.get(params, "startIndex", "1") |> String.to_integer()
    filter = Map.get(params, "filter", "")

    resources =
      scim_behavior.get_paged_list(filter: filter, per_page: items_per_page, start: start_index - 1)
      |> Enum.map(&scim_behavior.user_to_scim_resource/1)

    response = %{
      schemas: @list_schemas,
      Resources: resources,
      itemsPerPage: items_per_page,
      startIndex: start_index,
      totalResults: length(resources)
    }

    conn
    |> json(response)
  end

  # https://developer.okta.com/standards/SCIM/#read-account-details-get-usersid
  def show(conn = %{assigns: %{behavior: scim_behavior}}, %{"id" => user_id}) do
    user_mod = scim_behavior.user_module()

    with {:get_user, {:ok, user = %^user_mod{}}} <- {:get_user, scim_behavior.get_user(user_id)} do
      conn
      |> json(scim_behavior.user_to_scim_resource(user))
    else
      {:get_user, {:error, :user_not_found}} ->
        conn
        |> put_status(404)
        |> json(user_not_found())
    end
  end

  # https://developer.okta.com/standards/SCIM/#create-account-post-users
  def create(conn = %{assigns: %{behavior: scim_behavior}}, scim_user) do
    with user <- scim_behavior.scim_resource_to_user(scim_user),
         {:ok, user} <- scim_behavior.add_user(user),
         response <- scim_behavior.user_to_scim_resource(user) do
      conn
      |> put_status(201)
      |> json(response)
    end
  end

  # Handle both PUT and PATCH via the same endpoint, depending on the schema type
  def update(conn, params = %{"schemas" => schemas}) do
    cond do
      schemas == ["urn:ietf:params:scim:api:messages:2.0:PatchOp"] ->
        patch_user(conn, params)

      "urn:ietf:params:scim:schemas:core:2.0:User" in schemas ->
        update_user(conn, params)
    end
  end

  # https://developer.okta.com/standards/SCIM/#deactivate-account-patch-usersid
  defp patch_user(conn = %{assigns: %{behavior: scim_behavior}}, %{
         "id" => user_id,
         "Operations" => operations
       }) do
    user_mod = scim_behavior.user_module()

    with {:get_user, {:ok, user = %^user_mod{}}} <- {:get_user, scim_behavior.get_user(user_id)},
         {:apply_ops, {:ok, user}} <- {:apply_ops, scim_behavior.apply_scim_operations_to_user(user, operations)},
         {:add_user, {:ok, user}} <- {:add_user, scim_behavior.update_user(user)} do
      conn
      |> json(scim_behavior.user_to_scim_resource(user))
    else
      {:get_user, {:error, :user_not_found}} ->
        conn
        |> put_status(404)
        |> json(user_not_found())
    end
  end

  # https://developer.okta.com/standards/SCIM/#update-account-details-put-usersid
  defp update_user(conn = %{assigns: %{behavior: scim_behavior}}, scim_user) do
    with user <- scim_behavior.scim_resource_to_user(scim_user),
         {:ok, user} <- scim_behavior.update_user(user),
         response <- scim_behavior.user_to_scim_resource(user) do
      json(conn, response)
    end
  end

  defp user_not_found() do
    %{
      schemas: ["urn:ietf:params:scim:api:messages:2.0:Error"],
      detail: "User not found",
      status: "404"
    }
  end
end
