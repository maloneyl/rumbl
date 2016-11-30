# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Rumbl.Repo
alias Rumbl.Category

# we've prevented the same category being added twice
# with unique constraint on name in the database (see migrations)
# so it'll just blow up if we do have duplicated categories here
for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Repo.insert!(%Category{name: category})
end
