# This VideoChannel will allow connections through join and
# also let users disconnect and send events.
# For consistency with OTP naming conventions,
# we'll refer to these features as callbacks.
defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  def join("videos:" <> video_id, _params, socket) do
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end

  # handle_in handles all incoming messages to a channel, pushed directly from the remote client
  def handle_in(event, params, socket) do
    user = Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    changeset =
      user
      |> build_assoc(:annotations, video_id: socket.assigns.video_id)
      |> Rumbl.Annotation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, annotation} ->
        # broadcast! sends an event to all the clients on this topic
        broadcast! socket, "new_annotation", %{
          id: annotation.id,
          user: Rumbl.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        }
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # handle_info receives OTP messages;
  # this callback is invoked whenever an Elixir message reaches the channel.
  # here we're matching on the periodic :ping message
  # handle_info is a loop;
  # each time, it returns the socket as the last tuple element for all callbacks
  # so that we can maintain a state.
  # def handle_info("new_annotation", params, socket) do
    # count = socket.assigns[:count] || 1
    # push socket, "ping", %{count: count} # the client picks this up with the channel.on("ping", callback) API

    # assign here transforms the socket by adding the new count.
    # Conceptually, we're taking a socket and returning a transformed socket.
    # {:noreply, assign(socket, :count, count + 1)}
  # end
end
