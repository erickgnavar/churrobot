defmodule Churrobot.UI do
  @moduledoc """
  Module used to build GoogleChat Card to present information
  """

  @help_commands [
    {"help", "Show help"},
    {"status", "Show unpaid offers"},
    {"history", "Show all the offers"},
    {"new {user} {offer}", "Add a new offer"},
    {"pay {id}", "Mark an ofer as paid"}
  ]

  @spec help :: map
  def help do
    bot_handle = Application.get_env(:churrobot, :handle)

    widgets =
      Enum.map(@help_commands, fn {title, description} ->
        %{
          "keyValue" => %{
            "topLabel" => "#{bot_handle} #{title}",
            "content" => description,
            "contentMultiline" => "false"
          }
        }
      end)

    %{
      "cards" => [
        %{
          "header" => %{
            "title" => "ChurroBot help",
            "subtitle" => "churrobot@resuelve.mx",
            "imageUrl" => "https://goo.gl/aeDtrS"
          },
          "sections" => [
            %{
              "widgets" => widgets
            }
          ]
        }
      ]
    }
  end

  @doc """
  Create card view from the given offers
  """
  @spec offers_card(list) :: map
  def offers_card([]) do
    %{"text" => "Empty"}
  end

  def offers_card(offers) do
    widgets = Enum.map(offers, &offer_widget/1)

    %{
      "cards" => [
        %{
          "header" => %{
            "title" => "ChurroBot status",
            "subtitle" => "churrobot@resuelve.mx",
            "imageUrl" => "https://goo.gl/aeDtrS"
          },
          "sections" => [
            %{
              "widgets" => widgets
            }
          ]
        }
      ]
    }
  end

  @spec offer_widget(map) :: map
  defp offer_widget(item) do
    %{
      "keyValue" => %{
        "topLabel" => item.user,
        "content" => "#{item.id}: #{item.offer}",
        "contentMultiline" => "false",
        "bottomLabel" => to_string(item.date)
      }
    }
  end
end
