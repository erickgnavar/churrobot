defmodule Churrobot.OffersManager do
  use GenServer

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{offers: []}}
  end

  @doc """
  Persiste state of genserver to gist
  """
  def persist_state() do
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  def add_offer(user, offer) do
    GenServer.cast(__MODULE__, {:add_offer, user, offer})
  end

  def mark_as_paid(id) do
    GenServer.cast(__MODULE__, {:pay, id})
  end

  # private

  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_offer, user, offer}, state) do
    tmp = %{
      id: length(state.offers) + 1,
      user: user,
      offer: offer,
      date: DateTime.utc_now(),
      paid: false
    }

    {:noreply, %{state | offers: [tmp | state.offers]}}
  end

  def handle_cast({:pay, id}, state) do
    new_offers =
      Enum.map(state.offers, fn item ->
        if to_string(item.id) == to_string(id) do
          %{item | paid: true}
        else
          item
        end
      end)

    {:noreply, %{state | offers: new_offers}}
  end
end
