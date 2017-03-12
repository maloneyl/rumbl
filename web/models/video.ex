defmodule Rumbl.Video do
  use Rumbl.Web, :model

  # because Ecto automatically defines the id field for us,
  # customizing the primary key is done with the @primary_key module attribute
  # autogenerate: true because id values are genearated by the database
  @primary_key {:id, Rumbl.Permalink, autogenerate: true}
  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :slug, :string
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category

    timestamps()
  end

  @required_fields ~w(url title description)
  @optional_fields ~w(category_id)
  # user_id is neither required nor optional because it doesn't come from external data

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-") # replace nonword chars with a -
  end

  # When we pass a struct like video to watch_path,
  # Phoenix automatically extracts its ID to use in the returned URL
  # because that's what's defined in this protocol by default.
  # We can implement Elixir protocols for any data structure,
  # and this implementation doesn't have to live in the same field as the video definition.
  defimpl Phoenix.Param, for: Rumbl.Video do # "implement the Phoenix.Param for the Rumbl.Video struct"
    def to_param(%{slug: slug, id: id}) do # to_param receives the video struct itself
      "#{id}-#{slug}"
    end
  end  
end

