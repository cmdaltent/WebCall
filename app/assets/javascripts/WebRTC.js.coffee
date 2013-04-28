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

class Channel
  @Client = new Faye.Client window.location.protocol + '//' + window.location.host + '/streaming' if not @Client?
  
  constructor: (@channel) ->
    if @channel[0] isnt '/'
      throw Error('A channel needs to start with a "/"!')
    @constructor.Client.subscribe @channel, (data) => @_onmessage data
    
  publish: (data) ->
    @constructor.Client.publish @channel, data
    
  subscribe: (fn) ->
    @_listeners = @_listeners or []
    @_listeners.push fn
    undefined
    
  unsubscribe: (fn) ->
    @_listeners = @_listeners.filter (tFn) ->
      tFn isnt fn
    undefined
      
  _onmessage: (data) ->
    @_listeners.forEach (fn) ->
      fn data
    
@Channel = Channel