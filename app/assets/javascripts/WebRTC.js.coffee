# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

###
Class Channel establishes Publish/Subscriber connections of Faye on client side.
Each Channel should be constructed with a route as parameter (e.g. /meetings/1).
Listeners can be added via channel.subscribe and removed via channel.unsubscribe.
Messages/data can be published via channel.publish.
All Faye internals are handled in this class, even a singleton-like client connection 
to the server is available as Channel.Client (in this case Channel must not be an 
instance variable - it's a class variable. 
### 


class @Utils
  S4 = ()->
      (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)
  
  @GUID: ->
    (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4())


class Channel
  @Client = new Faye.Client window.location.protocol + '//' + window.location.host + '/streaming' if not @Client?
  @Client.disable 'autodisconnect'
  __ClientID__ = Utils.GUID()
  
  constructor: (@channel) ->
    if @channel[0] isnt '/'
      @channel = '/' + @channel
    @_listeners = []
    @constructor.Client.subscribe @channel, (data) => 
      @_onmessage data
    
  publish: (data) ->
    console.debug @channel, 'C->S', data
    data['__SENDER__'] = __ClientID__
    @constructor.Client.publish @channel, data
    
  subscribe: (fn) ->
    @_listeners.push fn
    undefined
    
  unsubscribe: (fn) ->
    @_listeners = @_listeners.filter (tFn) ->
      tFn isnt fn
    undefined
    
  disconnect: () ->
    @constructor.Client.disconnect()
  
  getClientId: () ->
    __ClientID__

  _onmessage: (data) ->
    unless data['__SENDER__'] is __ClientID__
      delete data['__SENDER__']
      console.debug @channel, 'S->C', data
      @_listeners.forEach (fn) ->
        fn data
    
@Channel = Channel

class Participant
  constructor: (@whoami) ->
    @channel = new Channel ['meetings', meetingToken, @whoami.identifier].join '/'
    @connection

class WebRTC
  constructor: (@meetingId, name = 'Guest ('+Utils.GUID().split('-')[0]+')', userToken = Utils.GUID()) ->
    @participants = {}
    @localStream
    @channel = new Channel ['meetings', @meetingId, 'stream-control'].join '/'
    @whoami =
      name: name
      identifier: userToken + '_' + @channel.getClientId()
      userToken: userToken
      clientId: @channel.getClientId()
    @channel.subscribe (message) =>
      @processChannelMessages message
    @privateChannel = new Channel ['meetings', @meetingId, @whoami.identifier].join '/'
    @privateChannel.subscribe (message) =>
      @processChannelMessages message
    window.addEventListener 'beforeunload', () =>
      @_sayGoodBye()
      undefined
  
  getIdByConnection: (connection) ->
    return guid for guid, c of @connections when c is connection 

  processChannelMessages: (message) ->
    if @localStream?
      switch message.type
        when 'hello'
          @_createAndSendOffer(message.participant)
        when 'offer'
          console.log 'offer received'
          @_offerReceived(message.participant, message.sessionDescription)
        when 'answer'
          console.log 'answer'
          @participants[message.participant.identifier].connection.setRemoteDescription new RTCSessionDescription message.sessionDescription
        when 'candidate'
          @participants[message.participant.identifier].connection.addIceCandidate new RTCIceCandidate
            sdpMLineIndex: message.label,
            candidate: message.candidate
        when 'GoodBye!'
          @_handleGoodBye message.participant
    
  _createAndSendOffer: (participant) ->
    @participants[participant.identifier] = new Participant(participant)
    connection = @participants[participant.identifier].connection = @_createConnection(@participants[participant.identifier]) 
    connection.guid = participant.identifier
    if @localStream? then connection.addStream @localStream
    connection.createOffer (sessionDescription) =>
      sessionDescription.sdp = preferOpus sessionDescription.sdp 
      connection.setLocalDescription sessionDescription
      @participants[participant.identifier].channel.publish
        type: 'offer',
        participant: @whoami,
        sessionDescription: sessionDescription      
    
  _offerReceived: (participant, remoteSessionDescription) ->
    @participants[participant.identifier] = new Participant(participant)
    connection = @participants[participant.identifier].connection = @_createConnection(@participants[participant.identifier])
    connection.guid = participant.identifier
    if @localStream? then connection.addStream @localStream
    connection.setRemoteDescription new RTCSessionDescription remoteSessionDescription
    connection.createAnswer (sessionDescription) =>
      connection.setLocalDescription sessionDescription
      @participants[participant.identifier].channel.publish
        type: 'answer',
        participant: @whoami,
        sessionDescription: sessionDescription

  _sayGoodBye: () ->
    @channel.publish
      participant: @whoami,
      type: 'GoodBye!'
    for guid, participant of @participants
      participant.connection.close()
    @channel.disconnect()
    undefined
        
  _handleGoodBye: (participant) ->
    EventBroker.fire 'rtc.user.left', @participants[participant.identifier]
    @participants[participant.identifier].connection.close()
    @_onRemoteStreamRemoved participant.identifier
    delete @participants[participant.identifier]

  _createConnection: (participant) ->
    connection = new RTCPeerConnection
      iceServers: [{
        url: 'stun:23.21.150.121'
      }, {
        url: 'turn:tudwebcall@webcall.markus-wutzler.de',
        credential: 'tudwebcall',
      }]
    
    #connection.onstatechange = () =>
    #  if connection.readyState is 'active' && @localStream?
    #    connection.addStream @localStream
    
    connection.onicecandidate = (event) =>
      if event.candidate
        participant.channel.publish {
          type: 'candidate',
          participant: @whoami,
          label: event.candidate.spdMLineIndex,
          id: event.candidate.sdpMid,
          candidate: event.candidate.candidate
        }
      else
        console.log 'End of candidates.'
      undefined
    
    connection.onaddstream = (event) =>
      EventBroker.fire 'rtc.user.join', participant
      @_onRemoteStreamAdded connection.guid, event.stream
#      attachMediaStream $('#remote-stream')[0], event.stream
      
    connection.onremovestream = () =>
      console.log event
      @_onRemoteStreamRemoved connection.guid
#      attachMediaStream $('#remote-stream')[0], undefined
    
    return connection
    
  getUserMedia: (video = true, audio = true)->
    navigator.getUserMedia {
      audio: audio,
      video: video,
    }, (stream) => 
      @_onUserMediaSuccess stream
    , (e) => 
      @_onUserMediaError e, video, audio
  
  _onUserMediaSuccess: (stream) ->
    @localStream = stream
    attachMediaStream $('#my-stream')[0], stream
    @channel.publish
      type: 'hello',
      participant: @whoami
    undefined
    
  _onUserMediaError: (error, video, audio) ->
    if error.code is 2 and video is true
      console.error "No Video available"
      @getUserMedia(false)
    console.error error

  _onRemoteStreamAdded: (guid, stream) ->
    el = $('#remote-stream-tmp').clone().attr('id',guid)
    attachMediaStream el[0], stream
    $('#streams').append($(el))
    undefined

  _onRemoteStreamRemoved: (guid) ->
    $('#'+guid).remove()
    console.log guid, 'stream removed'

@WebRTC = WebRTC

$(->
  try 
    window.meeting = new WebRTC(meetingToken, userName, userToken)
  catch error
    console.log(error)
  finally
    window.meeting?.getUserMedia()
    undefined  
)