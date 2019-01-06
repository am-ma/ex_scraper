defmodule ExScraperTest do
  use ExUnit.Case
  doctest ExScraper

  test "greets the world" do
    assert ExScraper.hello() == :world
  end
end
