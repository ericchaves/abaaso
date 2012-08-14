###
Global Observer wired to a State Machine

@class observer
@namespace abaaso
###
observer =
  
  # Collection of listeners
  listeners: {}
  
  # Boolean indicating if events are logged to the console
  log: false
  
  ###
  Adds a handler to an event
  
  @method add
  @param  {Mixed}    obj   Entity or Array of Entities or $ queries
  @param  {String}   event Event, or Events being fired (comma delimited supported)
  @param  {Function} fn    Event handler
  @param  {String}   id    [Optional / Recommended] The id for the listener
  @param  {String}   scope [Optional / Recommended] The id of the object or element to be set as 'this'
  @param  {String}   state [Optional] The state the listener is for
  @return {Mixed}          Entity, Array of Entities or undefined
  ###
  add: (obj, event, fn, id, scope, state) ->
    obj = utility.object(obj)
    scope = scope or abaaso
    state = state or abaaso.state.current
    if obj instanceof Array
      return obj.each((i) ->
        observer.add i, event, fn, id, scope, state
      )
    event = event.explode()  if typeof event isnt "undefined"
    id = utility.guid(true)  if typeof id is "undefined" or not /\w/.test(id)
    instance = null
    l = observer.listeners
    o = observer.id(obj)
    n = false
    c = abaaso.state.current
    globals = /body|document|window/i
    allowed = /click|key|mousedown|mouseup/i
    item = undefined
    add = undefined
    reg = undefined
    throw Error(label.error.invalidArguments)  if typeof o is "undefined" or event is null or typeof event is "undefined" or typeof fn isnt "function"
    event.each (i) ->
      n = false
      l[o] = {}  if typeof l[o] is "undefined"
      l[o][i] = {}  if typeof l[o][i] is "undefined" and (n = true)
      l[o][i][state] = {}  if typeof l[o][i][state] is "undefined"
      if n
        switch true
          when globals.test(o), not /\//g.test(o) and o isnt "abaaso"
            instance = obj
          else
            instance = null
        if instance isnt null and typeof instance isnt "undefined" and i.toLowerCase() isnt "afterjsonp" and (globals.test(o) or typeof instance.listeners is "function")
          add = (typeof instance.addEventListener is "function")
          reg = (typeof instance.attachEvent is "object" or add)
          if reg
            instance[(if add then "addEventListener" else "attachEvent")] ((if add then "" else "on")) + i, ((e) ->
              utility.stop e  if not globals.test(e.type) and not allowed.test(e.type)
              observer.fire obj, i, e
            ), false
      item =
        fn: fn
        scope: scope

      l[o][i][state][id] = item

    obj

  
  ###
  Gets the Observer id of arg
  
  @method id
  @param  {Mixed}  Object or String
  @return {String} Observer id
  @private
  ###
  id: (arg) ->
    id = undefined
    switch true
      when arg is abaaso
        id = "abaaso"
      when arg is global
        id = "window"
      when arg is not server and document
        id = "document"
      when arg is not server and document.body
        id = "body"
      else
        id = (if typeof arg.id isnt "undefined" then arg.id else ((if typeof arg.toString is "function" then arg.toString() else arg)))
    id

  
  ###
  Fires an event
  
  @method fire
  @param  {Mixed}  obj   Entity or Array of Entities or $ queries
  @param  {String} event Event, or Events being fired (comma delimited supported)
  @param  {Mixed}  arg   [Optional] Argument supplied to the listener
  @return {Mixed}        Entity, Array of Entities or undefined
  ###
  fire: (obj, event, arg) ->
    obj = utility.object(obj)
    if obj instanceof Array
      return obj.each((i) ->
        observer.fire obj[i], event, arg
      )
    event = event.explode()  if typeof event is "string"
    o = observer.id(obj)
    a = arg
    s = abaaso.state.current
    log = ($.observer.log or abaaso.observer.log)
    c = undefined
    l = undefined
    list = undefined
    throw Error(label.error.invalidArguments)  if typeof o is "undefined" or String(o).isEmpty() or typeof obj is "undefined" or typeof event is "undefined"
    event.each (e) ->
      list = observer.list(obj, e)
      l = list.all
      if typeof l isnt "undefined"
        utility.iterate l, (i, k) ->
          i.fn.call i.scope, a

      if s isnt "all"
        l = list[s]
        if typeof l isnt "undefined"
          utility.iterate l, (i, k) ->
            i.fn.call i.scope, a

      utility.log o + " fired " + e  if log

    obj

  
  ###
  Gets the listeners for an event
  
  @method list
  @param  {Mixed}  obj   Entity or Array of Entities or $ queries
  @param  {String} event Event being queried
  @return {Mixed}        Object or Array of listeners for the event
  ###
  list: (obj, event) ->
    obj = utility.object(obj)
    l = observer.listeners
    o = observer.id(obj)
    r = undefined
    switch true
      when typeof l[o] is "undefined" and typeof event is "undefined"
        r = {}
      when typeof l[o] isnt "undefined" and (typeof event is "undefined" or String(event).isEmpty())
        r = l[o]
      when typeof l[o] isnt "undefined" and typeof l[o][event] isnt "undefined"
        r = l[o][event]
      else
        r = {}
    r

  
  ###
  Adds a listener for a single execution
  
  @method once
  @param  {Mixed}    obj   Entity or Array of Entities or $ queries
  @param  {String}   event Event being fired
  @param  {Function} fn    Event handler
  @param  {String}   id    [Optional / Recommended] The id for the listener
  @param  {String}   scope [Optional / Recommended] The id of the object or element to be set as 'this'
  @param  {String}   state [Optional] The state the listener is for
  @return {Mixed}          Entity, Array of Entities or undefined
  ###
  once: (obj, event, fn, id, scope, state) ->
    guid = id or utility.genId()
    obj = utility.object(obj)
    scope = scope or abaaso
    state = state or abaaso.state.current
    throw Error(label.error.invalidArguments)  if typeof obj is "undefined" or event is null or typeof event is "undefined" or typeof fn isnt "function"
    if obj instanceof Array
      return obj.each((i) ->
        observer.once i, event, fn, id, scope, state
      )
    observer.add obj, event, ((arg) ->
      observer.remove obj, event, guid, state
      fn.call scope, arg
    ), guid, scope, state
    obj

  
  ###
  Removes listeners
  
  @method remove
  @param  {Mixed}  obj   Entity or Array of Entities or $ queries
  @param  {String} event [Optional] Event, or Events being fired (comma delimited supported)
  @param  {String} id    [Optional] Listener id
  @param  {String} state [Optional] The state the listener is for
  @return {Mixed}        Entity, Array of Entities or undefined
  ###
  remove: (obj, event, id, state) ->
    obj = utility.object(obj)
    state = state or abaaso.state.current
    if obj instanceof Array
      return obj.each((i) ->
        observer.remove i, event, id, state
      )
    instance = null
    l = observer.listeners
    o = observer.id(obj)
    switch true
      when typeof o is "undefined", typeof l[o] is "undefined"
        return obj
    if typeof event is "undefined" or event is null
      delete l[o]
    else
      event.explode().each (e) ->
        return obj  if typeof l[o][e] is "undefined"
        (if typeof id is "undefined" then l[o][e][state] = {} else delete l[o][e][state][id]
        )

    obj