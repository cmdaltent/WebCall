###
Class EventBroker

Example usage:

fn = (data) -> 
  console.log(data)

EventBroker.on('test', fn)
// add function 'fn' as listener for event 'test'

EventBroker.fire('test','Hallo')
// fire event 'test', listener functions executed with 'Hallo' as value for data
// returns 'Hallo'

EventBroker.off('test', fn)
// removes fn from listeners for event 'test'
### 

class EventBroker 
  constructor: () ->
    @_handlers = {};

  on: (evt, fn) ->
    unless @_handlers[evt]
      @_handlers[evt] = []
    @_handlers[evt].push fn
  
  off: (evt, fn) ->
    @_handlers = @_handlers[evt].filter (tFn) ->
      tFn isnt fn 
      
  fire: (evt, data) ->
    if @_handlers[evt]?
      fn data for fn in @_handlers[evt]
      undefined 

@EventBroker = new EventBroker()
