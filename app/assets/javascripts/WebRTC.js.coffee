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


class Utils
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
      throw Error('A channel needs to start with a "/"!')
    @constructor.Client.subscribe @channel, (data) => 
      @_onmessage data
    
  publish: (data) ->
    console.debug @channel, 'C->S', data
    data['__SENDER__'] = __ClientID__
    @constructor.Client.publish @channel, data
    
  subscribe: (fn) ->
    @_listeners = @_listeners or []
    @_listeners.push fn
    undefined
    
  unsubscribe: (fn) ->
    @_listeners = @_listeners.filter (tFn) ->
      tFn isnt fn
    undefined
    
  disconnect: () ->
    @constructor.Client.disconnect()

  _onmessage: (data) ->
    unless data['__SENDER__'] is __ClientID__
      delete data['__SENDER__']
      console.debug @channel, 'S->C', data
      @_listeners.forEach (fn) ->
        fn data
    
@Channel = Channel


class WebRTC
  
  `function preferOpus(sdp) {
    var sdpLines = sdp.split('\r\n');

    // Search for m line.
    for (var i = 0; i < sdpLines.length; i++) {
        if (sdpLines[i].search('m=audio') !== -1) {
          var mLineIndex = i;
          break;
        } 
    }
    if (mLineIndex === null)
      return sdp;

    // If Opus is available, set it as the default in m line.
    for (var i = 0; i < sdpLines.length; i++) {
      if (sdpLines[i].search('opus/48000') !== -1) {        
        var opusPayload = extractSdp(sdpLines[i], /:(\d+) opus\/48000/i);
        if (opusPayload)
          sdpLines[mLineIndex] = setDefaultCodec(sdpLines[mLineIndex], opusPayload);
        break;
      }
    }

    // Remove CN in m line and sdp.
    sdpLines = removeCN(sdpLines, mLineIndex);

    sdp = sdpLines.join('\r\n');
    return sdp;
  }

  function extractSdp(sdpLine, pattern) {
    var result = sdpLine.match(pattern);
    return (result && result.length == 2)? result[1]: null;
  }

  // Set the selected codec to the first in m line.
  function setDefaultCodec(mLine, payload) {
    var elements = mLine.split(' ');
    var newLine = new Array();
    var index = 0;
    for (var i = 0; i < elements.length; i++) {
      if (index === 3) // Format of media starts from the fourth.
        newLine[index++] = payload; // Put target payload to the first.
      if (elements[i] !== payload)
        newLine[index++] = elements[i];
    }
    return newLine.join(' ');
  }

  // Strip CN from sdp before CN constraints is ready.
  function removeCN(sdpLines, mLineIndex) {
    var mLineElements = sdpLines[mLineIndex].split(' ');
    // Scan from end for the convenience of removing an item.
    for (var i = sdpLines.length-1; i >= 0; i--) {
      var payload = extractSdp(sdpLines[i], /a=rtpmap:(\d+) CN\/\d+/i);
      if (payload) {
        var cnPos = mLineElements.indexOf(payload);
        if (cnPos !== -1) {
          // Remove CN payload from m line.
          mLineElements.splice(cnPos, 1);
        }
        // Remove CN line in sdp
        sdpLines.splice(i, 1);
      }
    }

    sdpLines[mLineIndex] = mLineElements.join(' ');
    return sdpLines;
  }`
  
  constructor: (@meetingId, @whoami = {name: '', token: Utils.GUID()})->
    @connections = {}
    @localStream
    @channel = new Channel '/meetings/' + @meetingId + '/stream-control'
    @channel.subscribe (message) =>
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
          @connections[message.participant.token].setRemoteDescription new RTCSessionDescription message.sessionDescription
        when 'candidate'
          @connections[message.participant.token].addIceCandidate new RTCIceCandidate
            sdpMLineIndex: message.label,
            candidate: message.candidate
        when 'GoodBye!'
          @_handleGoodBye message.participant
    
  _createAndSendOffer: (participant) ->
    connection = @connections[participant.token] = @_createConnection() 
    connection.guid = participant.token
    if @localStream? then connection.addStream @localStream
    connection.createOffer (sessionDescription) =>
      sessionDescription.sdp = preferOpus sessionDescription.sdp 
      connection.setLocalDescription sessionDescription
      @channel.publish
        type: 'offer',
        participant: @whoami,
        sessionDescription: sessionDescription      
    
  _offerReceived: (participant, remoteSessionDescription) ->
    connection = @connections[participant.token] = @_createConnection()
    connection.guid = participant.token
    if @localStream? then connection.addStream @localStream
    connection.setRemoteDescription new RTCSessionDescription remoteSessionDescription
    connection.createAnswer (sessionDescription) =>
      connection.setLocalDescription sessionDescription
      @channel.publish
        type: 'answer',
        participant: @whoami,
        sessionDescription: sessionDescription

  _sayGoodBye: () ->
    console.log 'client goodbye'
    @channel.publish
      participant: @whoami,
      type: 'GoodBye!'
    for guid, connection of @connections
      connection.close()
    @channel.disconnect()
    undefined
        
  _handleGoodBye: (participant) ->
    @connections[participant.token].close()
    delete @connections[participant.token]

  _createConnection: ->
    connection = new RTCPeerConnection
      iceServers: [{
        url: 'stun:23.21.150.121'
      }]
    
    #connection.onstatechange = () =>
    #  if connection.readyState is 'active' && @localStream?
    #    connection.addStream @localStream
    
    connection.onicecandidate = (event) =>
      if event.candidate
        @channel.publish {
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
      console.log '#onaddstream'
      console.log event
      @_onRemoteStreamAdded connection.guid, event.stream
#      attachMediaStream $('#remote-stream')[0], event.stream
      
    connection.onremovestream = () =>
      console.log event
      @_onRemoteStreamAdded connection.guid
#      attachMediaStream $('#remote-stream')[0], undefined
    
    return connection
    
  getUserMedia: ->
    navigator.getUserMedia {
      audio: true,
      video: true,
    }, (stream) => 
      @_onUserMediaSuccess stream
    , (e) => 
      @_onUserMediaError e
  
  _onUserMediaSuccess: (stream) ->
    @localStream = stream
    attachMediaStream $('#my-stream')[0], stream
    @channel.publish
      type: 'hello',
      participant: @whoami
    undefined
    
  _onUserMediaError: (error) ->
    console.error error

  _onRemoteStreamAdded: (guid, stream) ->
    el = (document.createElement('video'))
    el.id = guid
    attachMediaStream el, stream
    $(el).attr 'autoplay', 'autoplay'
    $('#remote-streams-bar').append $ el
    undefined

  _onRemoteStreamRemoved: (guid) ->
    $('#'+guid).remove()
    console.log guid, 'stream removed'

@WebRTC = WebRTC

$(->
  try 
    window.meeting = new WebRTC(meetingId)
    window.meeting.getUserMedia()
  catch error
    console.log error
  finally
    undefined  
)