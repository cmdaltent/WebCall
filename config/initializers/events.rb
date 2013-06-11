WebsocketRails.setup do |config|
  config.log_level = :debug
  config.log_path = "#{Rails.root}/log/websocket_rails.log"
  config.standalone = false
  config.synchronize = false
end

WebsocketRails::EventMap.describe do
  subscribe :new_message, :to => ChatEventController, with_method: :new_message
  subscribe :new_user, :to => ChatEventController, with_method: :add_user
  subscribe :client_disconnected, :to => ChatEventController, with_method: :delete_user
end
