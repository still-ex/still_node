defmodule Still.Node.ProcessTest do
  use ExUnit.Case, async: true

  alias Still.Node.Process

  @js_file Path.dirname(__DIR__)
                |> Path.join("../../assets/index.js")
                |> Path.expand()

  describe "invoke/3" do
    test "calls a node function" do
      {:ok, _} = Process.start_link(file: @js_file)

      assert {:ok, "hello world"} = Process.invoke("echo", ["hello world"])
    end

    test "uses a node package" do
      {:ok, _} = Process.start_link(file: @js_file)

      assert {:ok, true} = Process.invoke("eq", ["hello", "hello"])
    end

    test "handles huge amounts of data" do
      {:ok, _} = Process.start_link(file: @js_file)

      {:ok, response} = Process.invoke("huge", [])

      assert String.length(response) == 100_000
    end
  end

  describe "invoke/4" do
    test "supports a custom process name" do
      {:ok, _} = Process.start_link(file: @js_file, name: "index")

      assert {:ok, "hello gabriel"} =
               Process.invoke("index", "hello", ["gabriel"], timeout: :infinity)
    end
  end
end
