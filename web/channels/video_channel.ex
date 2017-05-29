# This VideoChannel will allow connections through join and
# also let users disconnect and send events.
# For consistency with OTP naming conventions,
# we'll refer to these features as callbacks.
defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  def join("videos:" <> video_id, _params, socket) do
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
    # Sockets will hold all of the state for a given conversation.
    # Each socket can hold its own state in the socket.assigns field,
    # which typically holds a map.
    # For channels, the socket is transformed in a loop rather than a single pipeline.
    # The socket state will remain for the duration of a connection,
    # meaning that the socket state we add in join will be accessible later
    # as events come in and out of the channel.
  end
end
