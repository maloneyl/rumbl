# This VideoChannel will allow connections through join and
# also let users disconnect and send events.
# For consistency with OTP naming conventions,
# we'll refer to these features as callbacks.
defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  def join("videos:" <> video_id, _params, socket) do
    :timer.send_interval(5_000, :ping)
    {:ok, socket}
  end

  # handle_info receives OTP messages;
  # this callback is invoked whenever an Elixir message reaches the channel.
  # here we're matching on the periodic :ping message
  # handle_info is a loop;
  # each time, it returns the socket as the last tuple element for all callbacks
  # so that we can maintain a state.
  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count} # the client picks this up with the channel.on("ping", callback) API

    # assign here transforms the socket by adding the new count.
    # Conceptually, we're taking a socket and returning a transformed socket.
    {:noreply, assign(socket, :count, count + 1)}

    # Sockets will hold all of the state for a given conversation.
    # Each socket can hold its own state in the socket.assigns field,
    # which typically holds a map.
    # For channels, the socket is transformed in a loop rather than a single pipeline.
    # The socket state will remain for the duration of a connection,
    # meaning that the socket state we add in join will be accessible later
    # as events come in and out of the channel.
  end
end
