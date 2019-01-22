defmodule ExScraperCsv do
  @export_filepath "exports"
  @moduledoc """
  スクレイピング結果をCSV出力
  """

  def export(config_filename) do
    File.mkdir(@export_filepath)
    currenttime = :calendar.local_time
      |> Tuple.to_list
      |> Enum.map(fn tuple ->
        tuple
        |> Tuple.to_list
        |> Enum.join("")
      end)
      |> Enum.join("")

    createCsv(config_filename)
    |> Enum.map(fn {item_name, csv_content} ->
      file_path = "./" <> @export_filepath <> "/" <> currenttime <> "_" <> item_name <> ".csv"
      # export file
      File.touch!(file_path)
      File.write!(file_path, csv_content)
      # log
      IO.puts "export: " <> file_path
    end)
  end

  defp createCsv(config_filename) do
    {:ok, configs} = YamlElixir.read_from_file(config_filename)
    {:ok, scraping_result} = ExScraper.exec(config_filename)

    case configs do
      %{"pager_key" => _pager_key, "items" => item_configs}
        -> scrapingContentsListToCsv(scraping_result, item_configs)
      _ -> scrapingContentsToCsv(scraping_result)
    end
  end

  # 複数ページ
  defp scrapingContentsListToCsv(scraping_result, item_configs) do
    item_configs
    |> Enum.map(fn item_config ->
      %{"name" => item_name} = item_config

      csv_content = scraping_result
        |> Enum.flat_map(fn {_page, scraping_content} ->
          # 対象のitemを抽出
          scraping_content
          |> Enum.filter(fn {content_item_name, _content} ->
            item_name == content_item_name
          end)
        end)
        |> scrapingItemsToCsv

      {item_name, csv_content}
    end)
  end

  # 単一ページ
  defp scrapingContentsToCsv(scraping_result) do
    scraping_result
    |> Enum.map(fn {item_name, items} ->
      csv_content = scrapingItemsToCsv(items)

      {item_name, csv_content}
    end)
  end

  defp scrapingItemsToCsv(items) do
    items
    |> CSV.encode(headers: true)
    |> Enum.to_list
    |> to_string
  end
end
