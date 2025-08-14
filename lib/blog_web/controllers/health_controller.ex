defmodule BlogWeb.HealthController do
  use BlogWeb, :controller

  def check(conn, _params) do
    status = %{
      status: "healthy",
      timestamp: DateTime.utc_now(),
      version: Application.spec(:blog, :vsn) |> to_string(),
      checks: perform_health_checks()
    }

    if all_checks_passing?(status.checks) do
      conn
      |> put_status(200)
      |> json(status)
    else
      conn
      |> put_status(503)
      |> json(%{status | status: "unhealthy"})
    end
  end

  defp perform_health_checks do
    %{
      database: check_database(),
      application: check_application()
    }
  end

  defp check_database do
    try do
      # Try to query the database to ensure connectivity
      case Showoff.Repo.query("SELECT 1", []) do
        {:ok, _} -> %{status: "healthy", message: "Database connection successful"}
        {:error, reason} -> %{status: "unhealthy", message: "Database error: #{inspect(reason)}"}
      end
    rescue
      error -> %{status: "unhealthy", message: "Database connection failed: #{inspect(error)}"}
    end
  end

  defp check_application do
    # Basic application health check
    %{status: "healthy", message: "Application is running"}
  end

  defp all_checks_passing?(checks) do
    Enum.all?(checks, fn {_name, check} -> check.status == "healthy" end)
  end
end
