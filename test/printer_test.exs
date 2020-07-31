defmodule PrinterTest do
  use ExUnit.Case
  doctest Issues

  import Issues.Printer,
    only: [
      pad: 2,
      print_row: 2,
      calculate_columns: 2,
      print_headers: 1,
      filter_and_convert_to_string: 2,
      print: 2
    ]

  import ExUnit.CaptureIO

  describe "print/1" do
    test "prints the whole table" do
      issues = [
        %{"a" => "123", "b" => "4343", "c" => "545454"},
        %{"a" => "12345", "b" => "43", "c" => "54"}
      ]

      columns = ["c", "a"]

      assert capture_io(fn -> print(issues, columns) end) == """
             +------+-----+
             |c     |a    |
             +------+-----+
             |545454|123  |
             |54    |12345|
             +------+-----+
             """
    end
  end

  describe "pad/3" do
    test "pads string correctly" do
      assert pad("string", 10) == "string    "
    end

    test "dont pad if offset is smaller than string" do
      assert pad("string", 5) == "string"
    end
  end

  describe "calculate_columns/2" do
    test "returns the max size of each column" do
      issues = [
        %{"a" => "123", "b" => "4343", "c" => "545454"},
        %{"a" => "12345", "b" => "43", "c" => "54"}
      ]

      columns = ["c", "a"]
      assert calculate_columns(issues, columns) == [{"c", 6}, {"a", 5}]
    end
  end

  describe "print_headers/1" do
    test "prints headers with correct padding and pipes" do
      columns = [{"a", 5}, {"b", 3}, {"c", 10}]

      assert capture_io(fn -> print_headers(columns) end) == """
             +-----+---+----------+
             |a    |b  |c         |
             +-----+---+----------+
             """
    end

    test "changes number to # when printing headers" do
      columns = [{"a", 5}, {"number", 10}]

      assert capture_io(fn -> print_headers(columns) end) == """
             +-----+----------+
             |a    |#         |
             +-----+----------+
             """
    end
  end

  describe "print_row/2" do
    test "prints row based on issues and column size" do
      issue = %{"a" => "123", "b" => "4343", "c" => "545454"}

      columns = [{"c", 7}, {"a", 7}, {"b", 6}]

      assert capture_io(fn -> print_row(issue, columns) end) == """
             |545454 |123    |4343  |
             """
    end
  end

  describe "filter_and_convert_to_string" do
    test "removes unused columns from issue list" do
      issues = [
        %{"a" => "123", "b" => "4343", "c" => "545454"},
        %{"a" => "12345", "b" => "43", "c" => "54"}
      ]

      filtered_issues = [
        %{"a" => "123", "c" => "545454"},
        %{"a" => "12345", "c" => "54"}
      ]

      assert filter_and_convert_to_string(issues, ["a", "c"]) == filtered_issues
    end

    test "changes all values to string" do
      issues = [
        %{"a" => "123", "b" => 4343, "c" => "545454"},
        %{"a" => "12345", "b" => 43, "c" => "54"}
      ]

      parsed_issues = [
        %{"a" => "123", "b" => "4343"},
        %{"a" => "12345", "b" => "43"}
      ]

      assert filter_and_convert_to_string(issues, ["a", "b"]) == parsed_issues
    end
  end
end
