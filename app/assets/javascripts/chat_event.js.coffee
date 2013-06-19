# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.Chat = {}

class Chat.User
  constructor: (@user)->
  serialize:=>{
	  source_user: @user
  }
    
class Chat.Controller
  messageTemplete: (message) ->
    html = 
      """
       <div class="message" style="display:none">
          <label class="label">
             #{message.user_name}
          </label>:&nbsp;&nbsp;
             #{message.msg_body}
        </div>
      """
    $(html)
       
  constructor: (url,useWebsocket) ->
    # $('#chat_room').hide()
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebsocket)
    @dispatcher.on_open = @getUserList
    @bindEvents()
    @target_user = 'ALL'
      
  getUserList: =>
    current_user = $('#current_user').text()
    @user = new Chat.User(current_user)
    @dispatcher.trigger 'new_user', @user.serialize()
		  
  bindEvents:=>
    that = this
    $('.toTalk').on 'click', (event) ->
      that.target_user = $(this).text()
      $('.control-label').html """Type your message _To: #{$(this).text()}"""
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    @dispatcher.bind 'new_message', @newMessage
    $('#toAll').on 'click', (e)=>
      that.target_user = "ALL"
      $('.control-label').html """Type your message:"""
   
  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    TARGET_USER  = message.target_user
    # console.log TARGET_USER
    if message.target_user == 'ALL' or message.user_name == @user.user or TARGET_USER ==@user.user
      @appendMessage message
      
  appendMessage: (message) =>
    std_message = @messageTemplete(message)
    $('#chat').append(std_message)
    std_message.slideDown 80

  sendMessage: (event) =>
    event.preventDefault()
    message = $('#message').val()
    @dispatcher.trigger 'new_message',{user_name:@user.user,msg_body:message,target_user:@target_user}
    # console.log @target_user
    $('#message').val('')
   
  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.messages:first').slideDown 100, ->
      $(this).remove()
 