# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.Chat = {}

class Chat.User
  constructor: (@user)->
  serialize:=>{user_name: @user}
    
class Chat.Controller
  messageTemplete: (message) ->
    html = 
      """
       <div class="message" style="display:none">
          <label class="label label-info">
             #{message.user_name}
          </label>:&nbsp;&nbsp;
             #{message.msg_body}
        </div>
      """
    $(html)
       
  constructor: (url,useWebsocket) ->
    $('#chat_room').hide()
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebsocket)
    @dispatcher.on_open = @getUserList
    @bindEvents()
  
  getUserList: =>
    current_user = $('#current_user').text()
    @user = new Chat.User(current_user)
    @dispatcher.trigger 'new_user', @user.serialize()
  
  bindEvents:=>
    @dispatcher.bind 'new_message', @newMessage
    $('.toTalk').on 'click',@gotoChat
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    
  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message
  
  appendMessage: (message) =>
    std_message = @messageTemplete(message)
    $('#chat').append(std_message)
    std_message.slideDown 80
  
  gotoChat: =>
    $('#chat_room').show() #if $('#chat_room').css('display') != 'none'
    
  sendMessage: (event) =>
    event.preventDefault()
    message = $('#message').val()
    @dispatcher.trigger 'new_message',{user_name:@user.user,msg_body:message}
    $('#message').val('')
   
  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.messages:first').slideDown 100, ->
      $(this).remove()