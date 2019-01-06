defmodule ExScraper do
  @moduledoc """
  Documentation for ExScraper.
  """

  @doc """
  設定ファイルの指定通りスクレイピングを実行

  ## Examples

      iex> ExScraper.exec "path_to_config-file/congih.yml"
      [
        %{"hogehoge": [
          %{"field1": "aaa", "field2": "bbb"},
          ...
        ]},
        %{"hugahuga": [...]}
      ]

  """
  def exec(config_filename) do
    {:ok, configs} = YamlElixir.read_from_file(config_filename)

    case configs do
      %{"url" => url, "pager_key" => pager_key, "items" => item_configs} ->
        scraping(url, pager_key, item_configs)
      %{"url" => url, "items" => item_configs} ->
        scraping(url, item_configs)
    end
  end

  # スクレイピング
  defp scraping(url, pager_key, item_configs) do
    scraping_with_page(url, pager_key, 1, item_configs, [])
  end
  defp scraping(url, item_configs) do
    case HTTPoison.get url do
      {:ok, response} -> {:ok, scraping_items(response.body, item_configs)}
      {:error, _} -> {:error, nil}
    end
  end

  # ページングしながら全ページ走破
  # TODO: 並行処理
  defp scraping_with_page(url, pager_key, page, item_configs, results) do
    connector_str = if String.contains?(url, "?"), do: "&", else: "?"
    pager_url = url <> connector_str <> pager_key <> "=" <> Integer.to_string(page)

    case scraping(pager_url, item_configs) do
      {:ok, result} ->
        # ※ページ内でコンテンツが1つも拾えない＝ページ走破が完了したとして処理を終了する
        result
        |> Enum.filter(fn ret ->
          val = ret |> Map.values |> List.first
          val != []
        end)
        |> Enum.empty?
        |> if do
          # 終了
          {:ok, results}
        else
          # 継続
          scraping_with_page(url, pager_key, page + 1, item_configs, [{page, result}] ++ results)
        end
      _ ->
        # 終了
        if Enum.empty?(results) do
          {:error, nil}
        else
          {:ok, ßresults}
        end
    end
  end

  # scraping (itemごと)
  defp scraping_items(body, item_configs) do
    item_configs
    |> Enum.map(fn item_config ->
      scraping_item(body, item_config)
    end)
  end

  # 要素（item）ごとにスクレイピング処理を実施
  defp scraping_item(body, %{"name" => itemname, "selector" => selector, "fields" => field_configs}) do
    items = Floki.find(body, selector)
      |> Enum.map(fn floki_item ->
        item_html = Floki.raw_html(floki_item)

        item = %{}
        # fieldをそれぞれ取り出してitemに設定
        field_configs
        |> Enum.map(fn field_config ->
          %{"name" => fieldname, "selector" => field_selector} = field_config

          field = Floki.find(item_html, field_selector)
            |> Floki.text
            |> String.trim

          Map.put(item, fieldname, field)
        end)
      end)

    %{itemname => items}
  end
end
