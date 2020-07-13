defmodule Issues.GithubIssues do
  @headers [
    "User-agent": "Elixir barboza.cardoso@gmail.com",
    Authorization: "token c0e43d3a627bf986818d5d5884831f6089a01587"
  ]

  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@headers)
    |> handle_response()
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {
      status_code |> check_for_error,
      body |> Poison.Parser.parse!(%{})
    }
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
