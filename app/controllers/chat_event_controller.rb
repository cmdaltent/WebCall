class ChatEventController < WebsocketRails::BaseController
#   
  # observe {
    # if connection_store.each_user.count > 0
      # puts 'it worked.'
    # end
# 
    # if message_counter > 10
      # puts 'message counter needs to be dumped'
      # self.message_counter = 0
    # end
  # }

  observe(:new_message) {
    puts "message observer fired for #{message}."
  }

  attr_accessor :message_counter

  def initialize_session
    puts "Session Initialized.\n"
    # @message_counter = 0
  end

  def new_message
    puts "Message from: #{message}\n"
    puts "Message from UID: #{client_id}\n"
    # @message_counter = @message_counter +  1
    broadcast_message :new_message, message
  end

  def add_user
    #puts "request: #{request.inspect}"
    # put data_store
    # data_store[:user] = message
    connection_store[:user] = message
    puts "storing user in data store\n"
    broadcast_user_list
  end

  def delete_user
    connection_store.remove_client
    # broadcast_message :new_message, {user_name: 'System', msg_body: "Client #{client_id} disconnected"}
    broadcast_user_list
  end

  def broadcast_user_list
    users = connection_store.each_user
    puts "broadcasting user list: #{users}\n"
    broadcast_message :user_list, users
  end

end
