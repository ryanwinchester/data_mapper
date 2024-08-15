defmodule DataMapperTest do
  use ExUnit.Case

  defmodule TestMapper do
    use DataMapper,
      mappings: %{
        "someFoo" => :foo,
        "someBar" => :bar,
        "extraThing" => :extra_thing
      }

    @impl DataMapper
    def map_field({_, nil}), do: nil
    def map_field({:bar, value}), do: value * 1000
    def map_field({_key, value}), do: value
  end

  test "maps and overrides map_field/2" do
    input = %{"someFoo" => 100, "someBar" => 2, "extraThing" => nil, "ignored" => "hello"}
    output = TestMapper.map(input)

    assert output == %{foo: 100, bar: 2000, extra_thing: nil}
  end

  defmodule TestPostMapTransformMapper do
    use DataMapper,
      mappings: %{
        "someFoo" => :foo,
        "someBar" => :bar,
        "extraThing" => :extra_thing
      }

    @impl DataMapper
    def post_map_transform(output) do
      output
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Enum.into(%{})
    end

    @impl DataMapper
    def map_field({_, nil}), do: nil
    def map_field({:bar, value}), do: value * 1000
    def map_field({_key, value}), do: value
  end

  test "maps and overrides post_map_transform/1" do
    input = %{"someFoo" => 100, "someBar" => 2, "extraThing" => nil, "ignored" => "hello"}
    output = TestPostMapTransformMapper.map(input)

    assert output == %{foo: 100, bar: 2000}
  end

  defmodule TestNestedMapper do
    use DataMapper,
      mappings: %{
        "a" => :a,
        "b" => :b,
        "extra" => :extra,
        "nested" => {:nested, %{"foo" => :foo}},
        "flattened" => %{
          "f1" => :flattened_1,
          "f2" => :flattened_2
        }
      }

    @impl DataMapper
    def map_field({:b, value}), do: value * 1000
    def map_field({_key, value}), do: value
  end

  test "maps nested map" do
    input = %{
      "a" => 100,
      "b" => 2,
      "nested" => %{"foo" => :grub},
      "flattened" => %{"f1" => false, "f2" => "what"}
    }

    output = TestNestedMapper.map(input)

    assert output == %{
             a: 100,
             b: 2000,
             nested: %{foo: :grub},
             flattened_1: false,
             flattened_2: "what"
           }
  end
end
