defmodule ChatterWeb.RoomChannel do
  use ChatterWeb, :channel

  alias ChatterWeb.Presence

  def join("room:lobby", _, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user, %{
        online_at: System.system_time(:milli_seconds)
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    broadcast!(socket, "message:new", %{
      user: socket.assign.user,
      body: message,
      timestamp: :os.system_time(:milli_seconds)
    })
  end
end
