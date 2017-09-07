defmodule Checker.Gesh do
  require Logger

  def fetch() do
    Logger.info "#{__MODULE__} fetching data"
    with {:ok, 200, _headers, client} <- :hackney.request(:get, "http://gesh.info/svodki", [], "", []),
         {:ok, body} <- :hackney.body(client),
         %{"date" => date, "content" => data} <- Regex.named_captures(
           ~r{<td class="td-center-news">(?<content><a href="http://gesh.info/svodki/.*?><strong>(?<date>.*?)</strong>.*?)</td>}m,
           body),
         {:ok, data} <- Pandex.html_to_markdown_strict(data),
         %{"day" => str_day, "month" => str_month, "year" => str_year} <- Regex.named_captures(~r/^(?<day>\d+)\s+(?<month>\S+)\s+(?<year>\d+)$/, date),
         {day, ""} <- Integer.parse(str_day),
         {:ok, month} <- str_to_month(str_month),
         {year, ""} <- Integer.parse(str_year)
      do
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

  ### helpers
  defp str_to_month("январ" <> _), do: {:ok, 1}
  defp str_to_month("февра" <> _), do: {:ok, 2}
  defp str_to_month("март"  <> _), do: {:ok, 3}
  defp str_to_month("апрел" <> _), do: {:ok, 4}
  defp str_to_month("ма"    <> _), do: {:ok, 5}
  defp str_to_month("июн"   <> _), do: {:ok, 6}
  defp str_to_month("июл"   <> _), do: {:ok, 7}
  defp str_to_month("авгус" <> _), do: {:ok, 8}
  defp str_to_month("сентя" <> _), do: {:ok, 9}
  defp str_to_month("октяб" <> _), do: {:ok, 10}
  defp str_to_month("ноябр" <> _), do: {:ok, 11}
  defp str_to_month("декаб" <> _), do: {:ok, 12}
  defp str_to_month(_), do: :error

end
