defmodule Checker.Sheregeshsu do
  require Logger

  def fetch() do
    Logger.info "#{__MODULE__} fetching data"
    with {:ok, 200, _headers, client} <- :hackney.request(:get, "http://sheregesh.su/svodki", [], "", timeout: 600000),
         {:ok, body} <- :hackney.body(client) do
      latest = Regex.named_captures(
        ~r{(?<content><div [^>]*views-row-first".*?<div [^>]*views-field-created\b.*?<span[^>]*?>(?<day>\d\d?)\.(?<month>\d\d?)\.(?<year>\d+).*?)<div [^>]*views\-row\-2}s,
        body
      )

      {:ok, data} = Map.fetch(latest, "content")
      {:ok, data} = Pandex.html_to_markdown_strict(data)

      data = Regex.replace(~r{</?span[^>]*>}, data, "")
      |> String.replace("\n\n", "::::::")
      |> String.replace("\n", " ")
      |> String.replace("::::::", "\n\n")

      {:ok, year} = Map.fetch(latest, "year")
      {:ok, month} = Map.fetch(latest, "month")
      {:ok, day} = Map.fetch(latest, "day")
      date = Timex.to_date({String.to_integer(year),
                            String.to_integer(month),
                            String.to_integer(day)})
      {date, data}
    else
      other ->
        Logger.warn "#{__MODULE__} fetch fail: #{inspect other}"
        nil
    end
  end

  def start_link() do
    Checker.start_link("sheregesh.su", &fetch/0)
  end

end
