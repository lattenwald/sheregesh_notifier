defmodule Checker.Gesh do
  require Logger

  def fetch() do
    Logger.info "#{__MODULE__} fetching data"
    with {:ok, 200, _headers, client} <- :hackney.request(:get, "http://gesh.info/svodki", [], "", []),
         {:ok, body} <- :hackney.body(client) do
      latest = Regex.named_captures(
        ~r{<td class="td-center-news">(?<content><a href="http://gesh.info/svodki/.*?><strong>(?<date>.*?)</strong>.*?)</td>}m,
        body)
      {:ok, date} = Map.fetch(latest, "date")
      {:ok, data} = Map.fetch(latest, "content")
      {:ok, data} = Pandex.html_to_markdown_strict(data)
      data =
        data
        |> String.replace("**", "::::::")
        |> String.replace("*", "_")
        |> String.replace("::::::", "*")
        |> String.replace("[*", "[")
        |> String.replace("*]", "]")
        |> String.replace("\n\n", "::::::")
        |> String.replace("\n", " ")
        |> String.replace("::::::", "\n\n")

      date_m = Regex.named_captures(~r/^(?<day>\d+)\s+(?<month>\S+)\s+(?<year>\d+)$/, date)
      day = date_m["day"] |> String.to_integer
      month = case date_m["month"] do
                "январ" <> _ -> 1
                "февра" <> _ -> 2
                "март"  <> _ -> 3
                "апрел" <> _ -> 4
                "ма"    <> _ -> 5
                "июн"   <> _ -> 6
                "июл"   <> _ -> 7
                "авгус" <> _ -> 8
                "сентя" <> _ -> 9
                "октяб" <> _ -> 10
                "ноябр" <> _ -> 11
                "декаб" <> _ -> 12
              end
      year = date_m["year"] |> String.to_integer
      date = Timex.to_date({year, month, day})

      {date, data}
    else
      other ->
        Logger.warn "#{__MODULE__} fetch fail: #{inspect other}"
        nil
    end
  end

  def start_link() do
    Checker.start_link("gesh.info", &fetch/0)
  end
end
