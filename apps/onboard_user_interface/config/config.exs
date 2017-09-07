# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :onboard_user_interface,
  namespace: OnboardUserInterface

# Configures the endpoint
config :onboard_user_interface, OnboardUserInterfaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rA4RnGJxqwMD5AZbAZaGKb00VudH8/FQYV/ctw8Q/3jt0TE5krRcst4hOXr3rxCN",
  render_errors: [view: OnboardUserInterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OnboardUserInterface.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
