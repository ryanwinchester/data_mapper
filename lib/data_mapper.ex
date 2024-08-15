defmodule DataMapper do
  @moduledoc """
  Define behaviours for a data-mapping module.
  """

  @callback map_list(input :: any) :: [map()]

  @callback map(input :: any) :: any()

  @callback map(input :: any, mappings :: map()) :: map()

  @callback map_field({key :: atom, value :: any}) :: value :: any

  @callback pre_map_list_transform(any) :: any

  @callback post_map_list_transform(any) :: [map()]

  @callback pre_map_transform(any) :: any

  @callback post_map_transform(any) :: any

  defmacro __using__(opts) do
    {mappings, opts} = Keyword.pop!(opts, :mappings)

    quote location: :keep do
      @behaviour DataMapper

      @doc """
      Map a list of inputs.
      """
      @impl DataMapper
      @spec map_list([map() | keyword()]) :: [map()]
      def map_list(inputs) do
        inputs
        |> pre_map_list_transform()
        |> Enum.map(&map/1)
        |> post_map_list_transform()
      end

      @doc """
      Maps input to the mappings described in the `opts`.
      """
      @impl DataMapper
      @spec map(map() | keyword()) :: any()
      def map(input) do
        input
        |> pre_map_transform()
        |> DataMapper.to_map()
        |> map(unquote(mappings), unquote(opts))
        |> post_map_transform()
      end

      ## Callbacks

      @doc """
      Maps the input to the given mappings.
      """
      @impl DataMapper
      @spec map(input :: map() | keyword(), mappings :: map(), opts :: keyword()) :: map()
      def map(input, mappings, opts \\ []) do
        Enum.reduce(mappings, opts[:into] || %{}, fn
          # Applies a DataMapper on a field.
          {from_key, {to_key, module}}, acc when is_atom(module) ->
            Map.put(acc, to_key, module.map(input[from_key]))

          # Applies a function to a field.
          {from_key, {to_key, fun}}, acc when is_function(fun) ->
            Map.put(acc, to_key, fun.(input[from_key]))

          # Nested mapping.
          {from_key, {to_key, sub_mapping}}, acc when is_map(sub_mapping) ->
            Map.put(acc, to_key, map(input[from_key], sub_mapping, opts))

          # Flatten nested mapping.
          {from_key, sub_mapping}, acc when is_map(sub_mapping) ->
            opts = Keyword.merge(opts, into: acc)

            case input[from_key] do
              data when is_list(data) -> Enum.map(data, &map(&1, sub_mapping, opts))
              data -> map(data, sub_mapping, opts)
            end

          # Normal mapping.
          {from_key, to_key}, acc ->
            if !opts[:preserve_keys?] and not Map.has_key?(input, from_key) do
              acc
            else
              Map.put(acc, to_key, map_field({to_key, input[from_key]}))
            end
        end)
      end

      @doc """
      Maps a field.
      """
      @impl DataMapper
      @spec map_field({atom, any}) :: any
      def map_field({_field, value}), do: value

      @doc """
      Transform the list before mapping.
      """
      @impl DataMapper
      def pre_map_list_transform(input), do: input

      @doc """
      Transform the list after mapping.
      """
      @impl DataMapper
      def post_map_list_transform(output), do: output

      @doc """
      Transform the input before mapping.
      """
      @impl DataMapper
      def pre_map_transform(input), do: input

      @doc """
      Transform the output after mapping.
      """
      @impl DataMapper
      def post_map_transform(output), do: output

      defoverridable(
        map_list: 1,
        map: 1,
        map: 2,
        map_field: 1,
        pre_map_list_transform: 1,
        post_map_list_transform: 1,
        pre_map_transform: 1,
        post_map_transform: 1
      )
    end
  end

  def to_map(input) when is_struct(input), do: Map.from_struct(input)
  def to_map(input) when is_map(input), do: input
  def to_map([{_, _} | _] = input), do: Map.new(input)
end
