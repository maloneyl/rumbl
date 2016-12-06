use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rumbl, Rumbl.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rumbl, Rumbl.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "maloney",
  password: "",
  database: "rumbl_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
  # add long timeout as below for pry sessions
  # ownership_timeout: 10 * 60 * 1000

# hashing passwords is intentionally expensive
# and makes our tests slow when we seed users with registration_changeset;
# we don't need that much security in tests so can ease up number of hashing rounds
# (this has made a huge difference: from 3.7s to 0.2s for the same 22 tests)
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
