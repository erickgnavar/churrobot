defmodule Churrobot.BotHandler do
  @moduledoc """
  Parse GoogleChat events
  """

  alias Churrobot.{OffersManager, UI}

  # TODO: replace this with a macro maybe
  @responses [
    {~r/status/, :status},
    {~r/history/, :history},
    {~r/new (?<user>\w+) (?<offer>\w+)/, :new_offer},
    {~r/pay (?<id>\d+)/, :pay},
    {~r/help/, :help}
  ]

  @doc """
  Generate returned response for a given event
  """
  @spec parse_message(map) :: map
  def parse_message(%{"type" => "ADDED_TO_SPACE", "user" => user}) do
    %{"text" => "Thanks #{user["displayName"]} for adding me :)"}
  end

  def parse_message(event) do
    event
    |> remove_bot_handle()
    |> match_responses()
  end

  # Remove bot handle for easy matching
  @spec remove_bot_handle(map) :: String.t()
  defp remove_bot_handle(event) do
    bot_handle = Application.get_env(:churrobot, :handle)
    position = ["message", "text"]

    new_text =
      event
      |> get_in(position)
      |> String.replace_leading(bot_handle, "")
      |> String.split(" ")
      |> Enum.reject(&(String.length(&1) == 0))
      |> Enum.join(" ")

    put_in(event, position, new_text)
  end

  defp match_responses(event) do
    @responses
    |> Enum.map(fn {regex, fun} ->
      case Regex.run(regex, get_in(event, ["message", "text"])) do
        nil -> nil
        # first value is the term itself
        # we send the event as parameter just in case we need to extract some information later
        [_ | values] -> apply(__MODULE__, fun, [event | values])
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> List.first()
    |> case do
      nil ->
        %{"text" => "Command not found"}

      response ->
        response
    end
  end

  def help(_) do
    UI.help()
  end

  def status(_) do
    %{offers: offers} = OffersManager.status()

    offers
    |> Enum.reject(& &1.paid)
    |> Enum.sort(&(&1.id < &2.id))
    |> UI.offers_card()
  end

  def history(_) do
    %{offers: offers} = OffersManager.status()

    offers
    |> Enum.sort(&(&1.id < &2.id))
    |> UI.offers_card()
  end

  def new_offer(_, user, offer) do
    OffersManager.add_offer(user, offer)

    %{"text" => "#{user} was added with #{offer}"}
  end

  def pay(event, id) do
    # TODO: validate who call this is the owner of the offer
    OffersManager.mark_as_paid(id)
    %{"text" => "Was paid"}
  end
end
