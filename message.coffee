###
Messaging between iframes

@class abaaso
@namespace abaaso
###
message =
  
  ###
  Clears the message listener
  
  @method clear
  @return {Object} abaaso
  ###
  clear: (state) ->
    state = "all"  if typeof state is "undefined"
    $.un global, "message", "message", state

  
  ###
  Posts a message to the target
  
  @method send
  @param  {Object} target Object to receive message
  @param  {Mixed}  arg    Entity to send as message
  @return {Object}        target
  ###
  send: (target, arg) ->
    try
      target.postMessage arg, "*"
    catch e
      error e, arguments_, this
    target

  
  ###
  Sets a handler for recieving a message
  
  @method recv
  @param  {Function} fn Callback function
  @return {Object}      abaaso
  ###
  recv: (fn, state) ->
    state = "all"  if typeof state is "undefined"
    $.on global, "message", fn, "message", global, state