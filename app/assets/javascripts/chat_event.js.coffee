# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.Chat = {}
class Chat.User

  constructor: (@user_name) ->
    
  serialize: =>
    {
      user_name: @user_name
    }

class Chat.Controller
  
  messageTemplate:(message)->
    html= 
          """
          <div class="message" style="display:none">
            <label class="label label-info">
              #{message.user_name}
            </label>:&nbsp;&nbsp;
            #{message.msg_body}
          </div>
          """
    $(html)
  
  #Todo: get user from user list.   
  userList:(userList)->
    user_HTML=""
    for user in userList
      user_HTML=user_HTML+"<li>#{user.user_name}</li>"
    $(user_HTML)
  
  constructor:(url,useWSs)->
    $('#chat_room').hide();
    @messageQueue=[]
    @dispatcher = new WebSocketRails(url,useWSs)
    @dispatcher.on_open=@getUserList
    @bindEvents()
    
  bindEvents:=>
    @dispatcher.bind 'new_message',@newMsg
    # @dispatcher.bind 'user_list', @updateUserList
    $('.toTalk').on 'click',@gotoChat
    $('#send').on 'click', @sendMsg
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13 #Enter Keycode
  
  newMsg:(message)=>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 100
    @appendMessage message
  
  sendMsg: (event) =>
    event.preventDefault()
    message = $('#message').val()
    # alert message
    @dispatcher.trigger 'new_message', {user_name: @user.user_name, msg_body: message}
    $('#message').val('')
  
    
  updateUserList:(usrList)=>
    $('#user-list').html @userList(usrList)
    
  # updateUserInfo:(event)=>
    # event.preventDefault()
    # @user.user_name = $('#user_name').val()#the current user for user id
    # $('#username').html @user.user_name
    # @dispatcher.trigger 'change_username',@user.serilize()
  
  appendMessage:(message)=>
    msgTemplate = @messageTemplate(message)#set all msg as a list
    $('#chat').append msgTemplate 
    msgTemplate.slideDown 80
    
  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.message:first').slideDown 120, ->
      $(this).remove()
  
  getUserList :=>
    new_user = $('#current_user').text() 
    @user = new Chat.User(new_user)
    @dispatcher.trigger 'new_user', @user.serilize()
  
  gotoChat:=>
    $('#chat_room').show() #if $('#chat_room').css('display') != 'none'

   
  destroyChat:->
    $('#chat_room').hide()
    #Todo:close the current ws connection.
  