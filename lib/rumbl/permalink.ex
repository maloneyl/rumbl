# Rumbl.Permalink is a custom type defined 
# according to the Ecto.Type behavior, which expects us to define
# type, cast, dump, load.
defmodule Rumbl.Permalink do 
  @behaviour Ecto.Type

  # returns the underlying Ecto type
  # here, we're building on top of :id
  def type, do: :id 

  # called when external data is passed into Ecto;
  # invoked when values in queries are interpolated
  # or also by the cast function in changesets;
  # often processes end-user input, so be both lenient and careful
  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do # we want only the leading integer in our slug
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast() do
    :error
  end

  # invoked when data is sent to the database;
  # cast does the dirty work of sanitizing input so we can expect integers
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  # invoked when data is loaded from the database
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end