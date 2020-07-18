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
    def map_field({_, nil} = field), do: field
    def map_field({:bar, field}), do: {:bar, field * 1000}
    def map_field(field), do: field
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
    def map_field({_, nil} = field), do: field
    def map_field({:bar, field}), do: {:bar, field * 1000}
    def map_field(field), do: field
  end

  test "maps and overrides post_map_transform/1" do
    input = %{"someFoo" => 100, "someBar" => 2, "extraThing" => nil, "ignored" => "hello"}
    output = TestPostMapTransformMapper.map(input)

    assert output == %{foo: 100, bar: 2000}
  end


  defmodule TestNestedMapper do
    use DataMapper,
      mappings: %{
        "someFoo" => :foo,
        "someBar" => :bar,
        "extraThing" => :extra_thing,
        "sub" => %{
          "bub" => :dub
        }
      }

    @impl DataMapper
    def map_field({_, nil} = field), do: field
    def map_field({:bar, field}), do: {:bar, field * 1000}
    def map_field(field), do: field
  end

  test "maps nested map" do
    input = %{"someFoo" => 100, "someBar" => 2, "sub" => %{"bub" => :grub}}
    output = TestNestedMapper.map(input)

    assert output == %{foo: 100, bar: 2000, dub: :grub}
  end
end
