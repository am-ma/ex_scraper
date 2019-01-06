# ExScraper
Yamlファイルの設定にそってスクレイピング処理を行います。

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_scraper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_scraper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_scraper](https://hexdocs.pm/ex_scraper).

## Usage

### 設定ファイル（単一ページ）
```Yaml
url: "https://hogehoge.co.jp" #スクレイピングの対象ページ
pager_key: page #ページング処理のパラメタ（※任意）
#取得する要素の定義
items:
  - 
    name: "item1"
    selector: ".container1-list > .item"
    fields:
      - {name: "name", selector: .name}
      - {name: "discription", selector: .desc}
  -
    name: "item2"
    selector: ".container2-list > .item"
    fields:
      - {name: "name", selector: .name}
      - {name: "discription", selector: .desc}
```