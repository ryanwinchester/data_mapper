defmodule DataMapper do
  @moduledoc """
  Define behaviours for a data-mapping module.
  """

  @callback map_list(input :: any) :: [map()]

  @callback map(input :: any) :: map()

  @callback map(input :: any, mappings :: map()) :: map()

  @callback map_field({key :: atom, value :: any}) :: {key :: atom, value :: any}

  @callback pre_map_list_transform(any) :: any

  @callback post_map_list_transform(any) :: [map()]

  @callback pre_map_transform(any) :: any

  @callback post_map_transform(any) :: map()

  defmacro __using__(opts) do
    mappings = Keyword.fetch!(opts, :mappings)

    quote do
      @behaviour DataMapper

      @doc """
      Map a list of inputs.
      """
      @impl true
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
      @impl true
      @spec map(map() | keyword()) :: map()
      def map(input) do
        input
        |> pre_map_transform()
        |> map(unquote(mappings))
        |> post_map_transform()
      end

      ## Callbacks

      @doc """
      Maps the input to the given mappings.
      """
      @impl true
      @spec map(input :: map() | keyword(), mappings :: map()) :: map()
      def map(input, mappings) do
        Enum.into(mappings, %{}, fn
          # Handle a nested map.
          {from_key, sub_mappings} when is_map(sub_mappings) ->
            map(input[from_key], sub_mappings)

          # The normal case, mapping the input key to the output key.
          {from_key, to_key} ->
            map_field({to_key, input[from_key]})
        end)
      end

      @doc """
      Maps a field.
      """
      @impl true
      @spec map_field({atom, any}) :: {atom, any}
      def map_field(field), do: field

      @doc """
      Transform the list before mapping.
      """
      @impl true
      def pre_map_list_transform(input), do: input

      @doc """
      Transform the list after mapping.
      """
      @impl true
      def post_map_list_transform(output), do: output

      @doc """
      Transform the input before mapping.
      """
      @impl true
      def pre_map_transform(input), do: input

      @doc """
      Transform the output after mapping.
      """
      @impl true
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
end
