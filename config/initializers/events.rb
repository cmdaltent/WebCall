WebsocketRails.setup do |config|
  config.standalone = false
  config.synchronize = false
end

WebsocketRails::EventMap.describe do
  subscribe :client_connected, to: ChatEventController, with_method: :client_connected
  subscribe :new_message, to: ChatEventController, with_method: :new_message
  subscribe :new_user, to: ChatEventController, with_method: :add_user
  # subscribe :change_username, to: ChatEventController, with_method: :change_username
  subscribe :client_disconnected, to: ChatEventController, with_method: :delete_user
  # subscribe :create_channel, to: ChatEventController, with_method: :new_channel
end
