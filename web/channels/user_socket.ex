# UserSocket uses a single connection to the server to handle all your channel processes.
defmodule Rumbl.UserSocket do
  use Phoenix.Socket

  @max_age 2 * 7 * 24 * 60 * 60 # two weeks

  ## Channels
  # Topics are strings that serve as identifiers, taking the form of topic:subtopic (resource name:resource ID).
  # Transports route events into your UserSocket, where they're dispatched 
  # into your channels based on topic patterns declared with the channel macro.
  channel "videos:*", Rumbl.VideoChannel

  ## Transport layers that handle the connection between your client and the server
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # def connect(_params, socket) do # lets everyone in by default
  #   {:ok, socket}
  # end
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end
  # deny connection by the client if invalid token
  def connect(_params, _socket), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Rumbl.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(_socket), do: nil
end
