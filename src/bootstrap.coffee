# concated before outro.js
error = utility.error
bootstrap = ->
  cleanup = undefined
  fn = undefined
  delete abaaso.bootstrap  if typeof abaaso.bootstrap is "function"
  
  # Describing the Client
  abaaso.client.size = client.size()
  client.version()
  client.mobile()
  client.tablet()
  
  # IE7 and older is not supported
  return  if client.ie and client.version < 8
  cleanup = (obj) ->
    nodes = []
    observer.remove obj
    nodes = array.cast(obj.childNodes)  if obj.childNodes.length > 0
    if nodes.length > 0
      nodes.each (i) ->
        cleanup i


  fn = (e) ->
    if /complete|loaded/.test(document.readyState)
      abaaso.init()  if typeof abaaso.init is "function"
      false

  if typeof Array::filter is "undefined"
    Array::filter = (fn) ->
      throw Error(label.error.invalidArguments)  if this is undefined or this is null or typeof fn isnt "function"
      i = null
      t = Object(this)
      nth = t.length >>> 0
      result = []
      prop = arguments_[1]
      val = null
      i = 0
      while i < nth
        if i of t
          val = t[i]
          result.push val  if fn.call(prop, val, i, t)
        i++
      result
  if typeof Array::forEach is "undefined"
    Array::forEach = (callback, thisArg) ->
      throw Error(label.error.invalidArguments)  if this is null or typeof callback isnt "function"
      T = undefined
      k = 0
      O = Object(this)
      len = O.length >>> 0
      T = thisArg  if thisArg
      while k < len
        kValue = undefined
        if k of O
          kValue = O[k]
          callback.call T, kValue, k, O
        k++
  if typeof Array::indexOf is "undefined"
    Array::indexOf = (obj, start) ->
      i = (start or 0)
      j = @length

      while i < j
        return i  if this[i] is obj
        i++
      -1
  if not server and typeof document.documentElement.classList is "undefined"
    ((view) ->
      ClassList = undefined
      getter = undefined
      proto = undefined
      target = undefined
      descriptor = undefined
      return  if ("HTMLElement" of view) and ("Element" of view)
      ClassList = (obj) ->
        classes = (if not obj.className.isEmpty() then obj.className.explode(" ") else [])
        self = this
        classes.each (i) ->
          self.push i

        @updateClassName = ->
          obj.className = @join(" ")

      getter = ->
        new ClassList(this)

      proto = ClassList["prototype"] = []
      target = (view.HTMLElement or view.Element)["prototype"]
      proto.add = (arg) ->
        unless array.contains(this, arg)
          @push arg
          @updateClassName()

      proto.contains = (arg) ->
        array.contains this, arg

      proto.remove = (arg) ->
        if array.contains(this, arg)
          array.remove this, arg
          @updateClassName()

      proto.toggle = (arg) ->
        array[(if array.contains(this, arg) then "remove" else "add")] this, arg
        @updateClassName()

      if Object.defineProperty
        descriptor =
          get: getter
          enumerable: (if not client.ie or client.version > 8 then true else false)
          configurable: true

        Object.defineProperty target, "classList", descriptor
      else if Object::__defineGetter__
        target.__defineGetter__ "classList", getter
      else
        throw Error("Could not create classList shim")
    ) global
  if typeof Function::bind is "undefined"
    Function::bind = (arg) ->
      fn = this
      slice = Array::slice
      args = slice.call(arguments_, 1)
      ->
        fn.apply arg, args.concat(slice.call(arguments_))
  
  # Cookie class is not relevant for server environment
  delete abaaso.cookie  if server
  
  # Binding helper & namespace to $
  $ = abaaso.$.bind($)
  utility.alias $, abaaso
  delete $.$

  delete $.bootstrap

  delete $.callback

  delete $.data

  delete $.init

  delete $.loading

  
  # Creating route.initial after alias() so it's not assumed
  abaaso.route.initial = null
  
  # Short cut to loading.create
  $.loading = abaaso.loading.create.bind($.loading)
  
  # Unbinding observer methods to maintain scope
  $.fire = abaaso.fire
  $.on = abaaso.on
  $.once = abaaso.once
  $.un = abaaso.un
  $.listeners = abaaso.listeners
  
  # Setting initial application state
  abaaso.state._current = abaaso.state.current = "initial"
  $.state._current = $.state.current = abaaso.state.current
  
  # Setting sugar
  unless server
    switch true
      when typeof global.$ is "undefined" or global.$ is null
        global.$ = $
      else
        global.a$ = $
        abaaso.aliased = "a$"
  
  # Hooking abaaso into native Objects
  utility.proto Array, "array"
  utility.proto Element, "element"  if typeof Element isnt "undefined"
  utility.proto HTMLDocument, "element"  if typeof HTMLDocument isnt "undefined"
  utility.proto Function, "function"
  utility.proto Number, "number"
  utility.proto String, "string"
  
  # Creating a singleton
  abaaso.constructor = abaaso
  
  # Creating error log
  $.error.log = abaaso.error.log = []
  
  # Setting events & garbage collection
  $.on global, "error", ((e) ->
    $.fire "error", e
  ), "error", global, "all"
  unless server
    $.on global, "hashchange", (->
      $.fire "beforeHash, hash, afterHash", location.hash
    ), "hash", global, "all"
    $.on global, "resize", (->
      $.client.size = abaaso.client.size = client.size()
      $.fire "resize", abaaso.client.size
    ), "resize", global, "all"
    $.on global, "load", ->
      $.fire("render").un "render"

    $.on global, "DOMNodeInserted", ((e) ->
      obj = e.target
      if typeof obj.id isnt "undefined" and obj.id.isEmpty()
        utility.genId obj
        obj.parentNode.fire "afterCreate", obj  if obj.parentNode instanceof Element
        $.fire "afterCreate", obj
    ), "mutation", global, "all"
    $.on global, "DOMNodeRemoved", ((e) ->
      cleanup e.target
    ), "mutation", global, "all"
    
    # Routing listener
    $.on "hash", ((arg) ->
      route.load arg  if $.route.enabled or abaaso.route.enabled
    ), "route", abaaso.route, "all"
  
  # abaaso.state.current getter/setter
  getter = undefined
  setter = undefined
  getter = ->
    @_current

  setter = (arg) ->
    throw Error(label.error.invalidArguments)  if arg is null or typeof arg isnt "string" or @current is arg or arg.isEmpty()
    abaaso.state.previous = abaaso.state._current
    abaaso.state._current = arg
    abaaso.fire arg

  switch true
    when (not client.ie or client.version > 8)
      utility.property abaaso.state, "current",
        enumerable: true
        get: getter
        set: setter

      utility.property $.state, "current",
        enumerable: true
        get: getter
        set: setter

    else # Pure hackery, only exists when needed
      abaaso.state.change = (arg) ->
        setter.call abaaso.state, arg
        abaaso.state.current = arg

      $.state.change = (arg) ->
        setter.call abaaso.state, arg
        abaaso.state.current = arg
  $.ready = true
  
  # Preparing init()
  switch true
    when server
      abaaso.init()
    when typeof global.define is "function"
      global.define "abaaso", ->
        abaaso.init()

    when (/complete|loaded/.test(document.readyState))
      abaaso.init()
    when typeof document.addEventListener is "function"
      document.addEventListener "DOMContentLoaded", abaaso.init, false
    when typeof document.attachEvent is "function"
      document.attachEvent "onreadystatechange", fn
    else
      utility.timer.init = utility.repeat(fn)