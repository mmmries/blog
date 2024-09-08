defmodule BlogWeb.AuthController do
  use BlogWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case auth do
      %{provider: :google, info: %{email: email}} ->
        # Handle successful authentication by storing the user's
        # email in the session and preventing fixation attacks
        conn
        |> put_session(:current_user, email)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome #{email}!")
        |> redirect(to: "/home")

      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: "/home")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed")
    |> redirect(to: "/home")
  end
end
