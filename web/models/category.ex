defmodule Rumbl.Category do
  use Rumbl.Web, :model

  schema "categories" do
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  # query here is a queryable
  # this function also returns a queryable
  def alphabetical(query) do
    # from: a macro that builds a query
    # c in query: pull rows (labeled c) from query schema
    from c in query, order_by: c.name
  end

  def names_and_ids(query) do
    from c in query, select: {c. name, c.id}
  end

  # not used; just example of select not returning a tuple
  def names(query) do
    from c in query, select: c.name
  end
end
