###
Utilities

@class utility
@namespace abaaso
###
utility =
  
  # Collection of timers
  timer: {}
  
  ###
  Queries the DOM using CSS selectors and returns an Element or Array of Elements
  
  Accepts comma delimited queries
  
  @method $
  @param  {String}  arg      Comma delimited string of target #id, .class, tag or selector
  @param  {Boolean} nodelist [Optional] True will return a NodeList (by reference) for tags & classes
  @return {Mixed}            Element or Array of Elements
  ###
  $: (arg, nodelist) ->
    
    # Blocking node or DOM query of unique URIs via $.on()
    return `undefined`  if server or String(arg).indexOf("?") > -1
    result = []
    tmp = []
    obj = undefined
    sel = undefined
    arg = arg.trim()
    nodelist = (nodelist is true)
    
    # Recursive processing, ends up below
    arg = arg.explode()  if arg.indexOf(",") > -1
    if arg instanceof Array
      arg.each (i) ->
        tmp.push $(i, nodelist)

      tmp.each (i) ->
        result = result.concat(i)

      return result
    
    # Getting Element(s)
    switch true
      when (/\s|>/.test(arg))
        sel = arg.split(" ").filter((i) ->
          true  if i.trim() isnt "" and i isnt ">"
        ).last()
        obj = document[(if sel.indexOf("#") > -1 and sel.indexOf(":") is -1 then "querySelector" else "querySelectorAll")](arg)
      when arg.indexOf("#") is 0 and arg.indexOf(":") is -1
        obj = (if isNaN(arg.charAt(1)) then document.querySelector(arg) else document.getElementById(arg.substring(1)))
      when arg.indexOf("#") > -1 and arg.indexOf(":") is -1
        obj = document.querySelector(arg)
      else
        obj = document.querySelectorAll(arg)
    
    # Transforming obj if required
    obj = array.cast(obj)  if typeof obj isnt "undefined" and obj isnt null and (obj not instanceof Element) and not nodelist
    obj = `undefined`  if obj is null
    obj

  
  ###
  Aliases origin onto obj
  
  @method alias
  @param  {Object} obj    Object receiving aliasing
  @param  {Object} origin Object providing structure to obj
  @return {Object}        Object receiving aliasing
  ###
  alias: (obj, origin) ->
    o = obj
    s = origin
    utility.iterate s, (v, k) ->
      getter = undefined
      setter = undefined
      switch true
        when (v not instanceof RegExp) and typeof v is "function"
          o[k] = v.bind(o[k])
        when (v not instanceof RegExp) and (v not instanceof Array) and v instanceof Object
          o[k] = {}  if typeof o[k] is "undefined"
          utility.alias o[k], s[k]
        else
          getter = ->
            s[k]

          setter = (arg) ->
            s[k] = arg


          utility.property o, k,
            enumerable: true
            get: getter
            set: setter
            value: s[k]


    obj

  
  ###
  Clones an Object
  
  @method clone
  @param {Object}  obj Object to clone
  @return {Object}     Clone of obj
  ###
  clone: (obj) ->
    clone = undefined
    switch true
      when obj instanceof Array
        [].concat obj
      when typeof obj is "boolean"
        Boolean obj
      when typeof obj is "function"
        obj
      when typeof obj is "number"
        Number obj
      when typeof obj is "string"
        String obj
      when not client.ie and not server and obj instanceof Document
        xml.decode xml.encode(obj)
      when obj instanceof Object
        clone = json.decode(json.encode(obj))
        if typeof clone isnt "undefined"
          clone.constructor = obj.constructor  if obj.hasOwnProperty("constructor")
          clone:: = obj::  if obj.hasOwnProperty("prototype")
        clone
      else
        obj

  
  ###
  Coerces a String to a Type
  
  @param  {String} value String to coerce
  @return {Mixed}        Typed version of the String
  ###
  coerce: (value) ->
    result = utility.clone(value)
    tmp = undefined
    switch true
      when (/^\d$/.test(result))
        result = number.parse(result)
      when (/^(true|false)$/i.test(result))
        result = /true/i.test(result)
      when result is "undefined"
        result = `undefined`
      when result is "null"
        result = null
      when (tmp = json.decode(result, true)) and typeof tmp isnt "undefined"
        result = tmp
    result

  
  ###
  Recompiles a RegExp by reference
  
  This is ideal when you need to recompile a regex for use within a conditional statement
  
  @param  {Object} regex     RegExp
  @param  {String} pattern   Regular expression pattern
  @param  {String} modifiers Modifiers to apply to the pattern
  @return {Boolean}          true
  ###
  compile: (regex, pattern, modifiers) ->
    regex.compile pattern, modifiers
    true

  
  ###
  Allows deep setting of properties without knowing
  if the structure is valid
  
  @method define
  @param  {String} args  Dot delimited string of the structure
  @param  {Mixed}  value Value to set
  @param  {Object} obj   Object receiving value
  @return {Object}       Object receiving value
  ###
  define: (args, value, obj) ->
    args = args.split(".")
    obj = this  if typeof obj is "undefined"
    value = null  if typeof value is "undefined"
    obj = abaaso  if obj is $
    p = obj
    nth = args.length
    args.each (i, idx) ->
      num = idx + 1 < nth and not isNaN(parseInt(args[idx + 1]))
      val = value
      i = parseInt(i)  unless isNaN(parseInt(i))
      
      # Creating or casting
      switch true
        when typeof p[i] is "undefined"
          p[i] = (if num then [] else {})
        when p[i] instanceof Object and num
          p[i] = array.cast(p[i])
        when p[i] instanceof Object, p[i] instanceof Array and not num
          p[i] = p[i].toObject()
        else
          p[i] = {}
      
      # Setting reference or value
      (if idx + 1 is nth then p[i] = val else p = p[i])

    obj

  
  ###
  Defers the execution of Function by at least the supplied milliseconds
  Timing may vary under "heavy load" relative to the CPU & client JavaScript engine
  
  @method defer
  @param  {Function} fn Function to defer execution of
  @param  {Number}   ms Milliseconds to defer execution
  @param  {Number}   id [Optional] ID of the deferred function
  @return {Object}      undefined
  ###
  defer: (fn, ms, id) ->
    ms = ms or 10
    id = id or utility.guid(true)
    op = ->
      delete utility.timer[id]

      fn()

    utility.timer[id] = setTimeout(op, ms)
    `undefined`

  
  ###
  Encodes a GUID to a DOM friendly ID
  
  @method domId
  @param  {String} GUID
  @return {String} DOM friendly ID
  @private
  ###
  domId: (arg) ->
    "a" + arg.replace(/-/g, "").slice(1)

  
  ###
  Error handling, with history in .log
  
  @method error
  @param  {Mixed}   e       Error object or message to display
  @param  {Array}   args    Array of arguments from the callstack
  @param  {Mixed}   scope   Entity that was "this"
  @param  {Boolean} warning [Optional] Will display as console warning if true
  @return {Undefined}       undefined
  ###
  error: (e, args, scope, warning) ->
    o = undefined
    if typeof e isnt "undefined"
      warning = (warning is true)
      o =
        arguments: args
        message: (if typeof e.message isnt "undefined" then e.message else e)
        number: (if typeof e.number isnt "undefined" then (e.number & 0xFFFF) else `undefined`)
        scope: scope
        stack: (if typeof e.stack is "string" then e.stack else `undefined`)
        timestamp: new Date().toUTCString()
        type: (if typeof e.type isnt "undefined" then e.type else "TypeError")

      console[(if not warning then "error" else "warn")] o.message  if typeof console isnt "undefined"
      $.error.log.push o
      $.fire "error", o
    `undefined`

  
  ###
  Creates a class extending obj, with optional decoration
  
  @method extend
  @param  {Object} obj Object to extend
  @param  {Object} arg [Optional] Object for decoration
  @return {Object}     Decorated obj
  ###
  extend: (obj, arg) ->
    o = undefined
    f = undefined
    throw Error(label.error.invalidArguments)  if typeof obj is "undefined"
    arg = {}  if typeof arg is "undefined"
    switch true
      when typeof Object.create is "function"
        o = Object.create(obj)
      else
        f = ->

        f:: = obj
        o = new f()
    utility.merge o, arg
    o

  
  ###
  Generates an ID value
  
  @method genId
  @param  {Mixed} obj [Optional] Object to receive id
  @return {Mixed}     Object or id
  ###
  genId: (obj) ->
    id = undefined
    switch true
      when obj instanceof Array, obj instanceof String
    , typeof obj is "string"
    , typeof obj isnt "undefined" and typeof obj.id isnt "undefined" and obj.id isnt ""
        return obj
    loop
      id = utility.domId(utility.guid(true))
      break unless typeof $("#" + id) isnt "undefined"
    if typeof obj is "object"
      obj.id = id
      obj
    else
      id

  
  ###
  Generates a GUID
  
  @method guid
  @param {Boolean} safe [Optional] Strips - from GUID
  @return {String}      GUID
  ###
  guid: (safe) ->
    safe = (safe is true)
    s = ->
      (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

    o = undefined
    o = (s() + s() + "-" + s() + "-4" + s().substr(0, 3) + "-" + s() + "-" + s() + s() + s()).toLowerCase()
    o = o.replace(/-/g, "")  if safe
    o

  
  ###
  Iterates an Object and executes a function against the properties
  
  Iteration can be stopped by returning false from fn
  
  @param  {Object}   obj Object to iterate
  @param  {Function} fn  Function to execute against properties
  @return {Object}       Object
  ###
  iterate: (obj, fn) ->
    i = undefined
    result = undefined
    throw Error(label.error.invalidArguments)  if typeof fn isnt "function"
    for i of obj
      if Object::hasOwnProperty.call(obj, i)
        result = fn.call(obj, obj[i], i)
        break  if result is false
    obj

  
  ###
  Renders a loading icon in a target element,
  with a class of "loading"
  
  @method loading
  @param  {Mixed} obj Entity or Array of Entities or $ queries
  @return {Mixed}     Entity, Array of Entities or undefined
  ###
  loading: (obj) ->
    l = abaaso.loading
    obj = utility.object(obj)
    if obj instanceof Array
      return obj.each((i) ->
        utility.loading i
      )
    throw Error(label.error.elementNotFound)  if l.url is null
    throw Error(label.error.invalidArguments)  if typeof obj is "undefined"
    
    # Setting loading image
    if typeof l.image is "undefined"
      l.image = new Image()
      l.image.src = l.url
    
    # Clearing target element
    obj.clear()
    
    # Creating loading image in target element
    obj.create("div",
      class: "loading"
    ).create "img",
      alt: label.common.loading
      src: l.image.src

    obj

  
  ###
  Writes argument to the console
  
  @method log
  @param  {String} arg String to write to the console
  @return undefined;
  @private
  ###
  log: (arg) ->
    try
      console.log "[" + new Date().toLocaleTimeString() + "] " + arg
    catch e
      error e, arguments_, this
    `undefined`

  
  ###
  Merges obj with arg
  
  @param  {Object} obj Object to decorate
  @param  {Object} arg Object to decorate with
  @return {Object}     Object to decorate
  ###
  merge: (obj, arg) ->
    utility.iterate arg, (v, k) ->
      obj[k] = utility.clone(v)

    obj

  
  ###
  Registers a module in the abaaso namespace
  
  IE8 will have factories (functions) duplicated onto $ because it will not respect the binding
  
  @method module
  @param  {String} arg Module name
  @param  {Object} obj Module structure
  @return {Object}     Module registered
  ###
  module: (arg, obj) ->
    throw Error(label.error.invalidArguments)  if typeof $[arg] isnt "undefined" or typeof abaaso[arg] isnt "undefined" or not obj instanceof Object
    abaaso[arg] = obj
    unless typeof obj is "function"
      $[arg] = {}
      utility.alias $[arg], abaaso[arg]
    $[arg]

  
  ###
  Returns Object, or reference to Element
  
  @method object
  @param  {Mixed} obj Entity or $ query
  @return {Mixed}     Entity
  @private
  ###
  object: (obj) ->
    (if typeof obj is "object" then obj else ((if obj.toString().charAt(0) is "#" then $(obj) else obj)))

  
  ###
  Sets a property on an Object, if defineProperty cannot be used the value will be set classically
  
  @method property
  @param  {Object} obj        Object to decorate
  @param  {String} prop       Name of property to set
  @param  {Object} descriptor Descriptor of the property
  @return {Object}            Object receiving the property
  ###
  property: (obj, prop, descriptor) ->
    throw Error(label.error.invalidArguments)  unless descriptor instanceof Object
    define = undefined
    define = (not client.ie or client.version > 8) and typeof Object.defineProperty is "function"
    delete descriptor.value  if define and typeof descriptor.value isnt "undefined" and typeof descriptor.get isnt "undefined"
    (if define then Object.defineProperty(obj, prop, descriptor) else obj[prop] = descriptor.value)
    obj

  
  ###
  Sets methods on a prototype object
  
  @method proto
  @param  {Object} obj  Object receiving prototype extension
  @param  {String} type Identifier of obj, determines what Arrays to apply
  @return {Object}      obj or undefined
  @private
  ###
  proto: (obj, type) ->
    
    # Collection of methods to add to prototypes
    i = undefined
    methods =
      array:
        add: (arg) ->
          array.add this, arg

        addClass: (arg) ->
          @each (i) ->
            i.addClass arg


        after: (type, args) ->
          a = []
          @each (i) ->
            a.push i.after(type, args)

          a

        append: (type, args) ->
          a = []
          @each (i) ->
            a.push i.append(type, args)

          a

        attr: (key, value) ->
          a = []
          @each (i) ->
            a.push i.attr(key, value)

          a

        before: (type, args) ->
          a = []
          @each (i) ->
            a.push i.before(type, args)

          a

        clear: (arg) ->
          @each (i) ->
            i.clear()


        clone: ->
          utility.clone this

        contains: (arg) ->
          array.contains this, arg

        create: (type, args, position) ->
          a = []
          @each (i) ->
            a.push i.create(type, args, position)

          a

        css: (key, value) ->
          @each (i) ->
            i.css key, value


        data: (key, value) ->
          a = []
          @each (i) ->
            a.push i.data(key, value)

          a

        diff: (arg) ->
          array.diff this, arg

        disable: ->
          @each (i) ->
            i.disable()


        destroy: ->
          @each (i) ->
            i.destroy()

          []

        each: (arg) ->
          array.each this, arg

        enable: ->
          @each (i) ->
            i.enable()


        find: (arg) ->
          a = []
          @each (i) ->
            i.find(arg).each (r) ->
              a.push r  unless a.contains(r)


          a

        fire: (event, arg) ->
          @each (i) ->
            i.fire event, arg


        first: ->
          array.first this

        get: (uri, headers) ->
          @each (i) ->
            i.get uri, headers

          []

        has: (arg) ->
          a = []
          @each (i) ->
            a.push i.has(arg)

          a

        hasClass: (arg) ->
          a = []
          @each (i) ->
            a.push i.hasClass(arg)

          a

        hide: ->
          @each (i) ->
            i.hide()


        html: (arg) ->
          unless typeof arg isnt "undefined"
            a = []
            @each (i) ->
              a.push i.html()

            a

        index: (arg) ->
          array.index this, arg

        indexed: ->
          array.indexed this

        intersect: (arg) ->
          array.intersect this, arg

        is: (arg) ->
          a = []
          @each (i) ->
            a.push i.is(arg)

          a

        isAlphaNum: ->
          a = []
          @each (i) ->
            a.push i.isAlphaNum()

          a

        isBoolean: ->
          a = []
          @each (i) ->
            a.push i.isBoolean()

          a

        isChecked: ->
          a = []
          @each (i) ->
            a.push i.isChecked()

          a

        isDate: ->
          a = []
          @each (i) ->
            a.push i.isDate()

          a

        isDisabled: ->
          a = []
          @each (i) ->
            a.push i.isDisabled()

          a

        isDomain: ->
          a = []
          @each (i) ->
            a.push i.isDomain()

          a

        isEmail: ->
          a = []
          @each (i) ->
            a.push i.isEmail()

          a

        isEmpty: ->
          a = []
          @each (i) ->
            a.push i.isEmpty()

          a

        isHidden: ->
          a = []
          @each (i) ->
            a.push i.isHidden()

          a

        isIP: ->
          a = []
          @each (i) ->
            a.push i.isIP()

          a

        isInt: ->
          a = []
          @each (i) ->
            a.push i.isInt()

          a

        isNumber: ->
          a = []
          @each (i) ->
            a.push i.isNumber()

          a

        isPhone: ->
          a = []
          @each (i) ->
            a.push i.isPhone()

          a

        keys: ->
          array.keys this

        last: (arg) ->
          array.last this

        listeners: (event) ->
          a = []
          @each (i) ->
            a = a.concat(i.listeners(event))

          a

        loading: ->
          @each (i) ->
            i.loading()


        on: (event, listener, id, scope, state) ->
          @each (i) ->
            i.on event, listener, id, (if typeof scope isnt "undefined" then scope else i), state


        once: (event, listener, id, scope, state) ->
          @each (i) ->
            i.once event, listener, id, (if typeof scope isnt "undefined" then scope else i), state


        position: ->
          a = []
          @each (i) ->
            a.push i.position()

          a

        prepend: (type, args) ->
          a = []
          @each (i) ->
            a.push i.prepend(type, args)

          a

        range: (start, end) ->
          array.range this, start, end

        remove: (start, end) ->
          array.remove this, start, end

        removeClass: (arg) ->
          @each (i) ->
            i.removeClass arg


        show: ->
          @each (i) ->
            i.show()


        size: ->
          a = []
          @each (i) ->
            a.push i.size()

          a

        text: (arg) ->
          @each (node) ->
            node = utility.object(node)  if typeof node isnt "object"
            node.text arg  if typeof node.text is "function"


        tpl: (arg) ->
          @each (i) ->
            i.tpl arg


        toggleClass: (arg) ->
          @each (i) ->
            i.toggleClass arg


        total: ->
          array.total this

        toObject: ->
          array.toObject this

        un: (event, id, state) ->
          @each (i) ->
            i.un event, id, state


        update: (arg) ->
          @each (i) ->
            element.update i, arg


        val: (arg) ->
          a = []
          type = null
          same = true
          @each (i) ->
            same = (type is i.type)  if type isnt null
            type = i.type
            a.push i.val(arg)  if typeof i.val is "function"

          (if same then a[0] else a)

        validate: ->
          a = []
          @each (i) ->
            a.push i.validate()

          a

      element:
        addClass: (arg) ->
          utility.genId this
          element.klass this, arg, true

        after: (type, args) ->
          utility.genId this
          element.create type, args, this, "after"

        append: (type, args) ->
          utility.genId this
          element.create type, args, this, "last"

        attr: (key, value) ->
          utility.genId this
          element.attr this, key, value

        before: (type, args) ->
          utility.genId this
          element.create type, args, this, "before"

        clear: ->
          utility.genId this
          element.clear this

        create: (type, args, position) ->
          utility.genId this
          element.create type, args, this, position

        css: (key, value) ->
          i = undefined
          utility.genId this
          if not client.chrome and (i = key.indexOf("-")) and i > -1
            key = key.replace("-", "")
            key = key.slice(0, i) + key.charAt(i).toUpperCase() + key.slice(i + 1, key.length)
          @style[key] = value
          this

        data: (key, value) ->
          utility.genId this
          element.data this, key, value

        destroy: ->
          element.destroy this

        disable: ->
          element.disable this

        enable: ->
          element.enable this

        find: (arg) ->
          utility.genId this
          element.find this, arg

        fire: (event, args) ->
          utility.genId this
          $.fire.call this, event, args

        genId: ->
          utility.genId this

        get: (uri, headers) ->
          @fire "beforeGet"
          cached = cache.get(uri)
          self = this
          (if not cached then uri.get((arg) ->
            self.html(arg).fire "afterGet"
          , (arg) ->
            self.fire "failedGet",
              response: client.parse(arg)
              xhr: arg

          , headers) else @html(cached.response).fire("afterGet"))
          this

        has: (arg) ->
          utility.genId this
          element.has this, arg

        hasClass: (arg) ->
          utility.genId this
          element.hasClass this, arg

        hide: ->
          utility.genId this
          element.hide this

        html: (arg) ->
          utility.genId this
          (if typeof arg is "undefined" then @innerHTML else @update(innerHTML: arg))

        is: (arg) ->
          utility.genId this
          element.is this, arg

        isAlphaNum: ->
          (if @nodeName is "FORM" then false else validate.test(alphanum: (if typeof @value isnt "undefined" then @value else element.text(this))).pass)

        isBoolean: ->
          (if @nodeName is "FORM" then false else validate.test(boolean: (if typeof @value isnt "undefined" then @value else element.text(this))).pass)

        isChecked: ->
          (if @nodeName isnt "INPUT" then false else @attr("checked"))

        isDate: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isDate() else element.text(this).isDate()))

        isDisabled: ->
          (if @nodeName isnt "INPUT" then false else @attr("disabled"))

        isDomain: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isDomain() else element.text(this).isDomain()))

        isEmail: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isEmail() else element.text(this).isEmail()))

        isEmpty: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isEmpty() else element.text(this).isEmpty()))

        isHidden: (arg) ->
          utility.genId this
          element.hidden this

        isIP: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isIP() else element.text(this).isIP()))

        isInt: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isInt() else element.text(this).isInt()))

        isNumber: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isNumber() else element.text(this).isNumber()))

        isPhone: ->
          (if @nodeName is "FORM" then false else (if typeof @value isnt "undefined" then @value.isPhone() else element.text(this).isPhone()))

        jsonp: (uri, property, callback) ->
          target = this
          arg = property
          fn = undefined
          fn = (response) ->
            self = target
            node = response
            prop = arg
            i = undefined
            nth = undefined
            result = undefined
            try
              if typeof prop isnt "undefined"
                prop = prop.replace(/]|'|"/g, "").replace(/\./g, "[").split("[")
                prop.each (i) ->
                  node = node[(if !!isNaN(i) then i else parseInt(i))]
                  throw Error(label.error.propertyNotFound)  if typeof node is "undefined"

                result = node
              else
                result = response
            catch e
              result = label.error.serverError
              error e, arguments_, this
            self.text result

          client.jsonp uri, fn, (->
            target.text label.error.serverError
          ), callback
          this

        listeners: (event) ->
          utility.genId this
          $.listeners.call this, event

        loading: ->
          utility.loading this

        on: (event, listener, id, scope, state) ->
          utility.genId this
          $.on.call this, event, listener, id, scope, state

        once: (event, listener, id, scope, state) ->
          utility.genId this
          $.once.call this, event, listener, id, scope, state

        prepend: (type, args) ->
          utility.genId this
          element.create type, args, this, "first"

        prependChild: (child) ->
          utility.genId this
          element.prependChild this, child

        position: ->
          utility.genId this
          element.position this

        removeClass: (arg) ->
          utility.genId this
          element.klass this, arg, false

        show: ->
          utility.genId this
          element.show this

        size: ->
          utility.genId this
          element.size this

        text: (arg) ->
          utility.genId this
          element.text this, arg

        toggleClass: (arg) ->
          utility.genId this
          element.toggleClass this, arg

        tpl: (arg) ->
          utility.tpl arg, this

        un: (event, id, state) ->
          utility.genId this
          $.un.call this, event, id, state

        update: (args) ->
          utility.genId this
          element.update this, args

        val: (arg) ->
          utility.genId this
          element.val this, arg

        validate: ->
          (if @nodeName is "FORM" then validate.test(this) else (if typeof @value isnt "undefined" then not @value.isEmpty() else not element.text(this).isEmpty()))

      function:
        reflect: ->
          utility.reflect this

      number:
        diff: (arg) ->
          number.diff this, arg

        fire: (event, args) ->
          $.fire.call @toString(), event, args
          this

        format: (delimiter, every) ->
          number.format this, delimiter, every

        half: (arg) ->
          number.half this, arg

        isEven: ->
          number.even this

        isOdd: ->
          number.odd this

        listeners: (event) ->
          $.listeners.call @toString(), event

        on: (event, listener, id, scope, state) ->
          $.on.call @toString(), event, listener, id, scope or this, state
          this

        once: (event, listener, id, scope, state) ->
          $.once.call @toString(), event, listener, id, scope or this, state
          this

        roundDown: ->
          number.round this, "down"

        roundUp: ->
          number.round this, "up"

        un: (event, id, state) ->
          $.un.call @toString(), event, id, state
          this

      string:
        allows: (arg) ->
          client.allows this, arg

        capitalize: ->
          string.capitalize this

        del: (success, failure, headers) ->
          client.request this, "DELETE", success, failure, null, headers

        escape: ->
          string.escape this

        expire: (silent) ->
          cache.expire this, silent

        explode: (arg) ->
          string.explode this, arg

        fire: (event, args) ->
          $.fire.call this, event, args

        get: (success, failure, headers) ->
          client.request this, "GET", success, failure, null, headers

        headers: (success, failure) ->
          client.request this, "HEAD", success, failure

        hyphenate: ->
          string.hyphenate this

        isAlphaNum: ->
          validate.test(alphanum: this).pass

        isBoolean: ->
          validate.test(boolean: this).pass

        isDate: ->
          validate.test(date: this).pass

        isDomain: ->
          validate.test(domain: this).pass

        isEmail: ->
          validate.test(email: this).pass

        isEmpty: ->
          string.trim(this) is ""

        isIP: ->
          validate.test(ip: this).pass

        isInt: ->
          validate.test(integer: this).pass

        isNumber: ->
          validate.test(number: this).pass

        isPhone: ->
          validate.test(phone: this).pass

        jsonp: (success, failure, callback) ->
          client.jsonp this, success, failure, callback

        listeners: (event) ->
          $.listeners.call this, event

        post: (success, failure, args, headers) ->
          client.request this, "POST", success, failure, args, headers

        put: (success, failure, args, headers) ->
          client.request this, "PUT", success, failure, args, headers

        on: (event, listener, id, scope, state) ->
          $.on.call this, event, listener, id, scope, state

        once: (event, listener, id, scope, state) ->
          $.once.call this, event, listener, id, scope, state

        options: (success, failure) ->
          client.request this, "OPTIONS", success, failure

        permissions: ->
          client.permissions this

        singular: ->
          string.singular this

        toCamelCase: ->
          string.toCamelCase this

        toNumber: ->
          number.parse this

        trim: ->
          string.trim this

        un: (event, id, state) ->
          $.un.call this, event, id, state

        uncapitalize: ->
          string.uncapitalize this

    utility.iterate methods[type], (v, k) ->
      utility.property obj::, k,
        value: v


    obj

  
  ###
  Returns an Object containing 1 or all key:value pairs from the querystring
  
  @method queryString
  @param  {String} arg [Optional] Key to find in the querystring
  @return {Object}     Object of 1 or all key:value pairs in the querystring
  ###
  queryString: (arg) ->
    arg = arg or ".*"
    obj = {}
    result = (if location.search.isEmpty() then null else location.search.replace("?", ""))
    item = undefined
    if result isnt null
      result = result.split("&")
      result.each (prop) ->
        item = prop.split("=")
        return  if item[0].isEmpty()
        switch true
          when typeof item[1] is "undefined", item[1].isEmpty()
            item[1] = ""
          when item[1].isNumber()
            item[1] = Number(item[1])
          when item[1].isBoolean()
            item[1] = (item[1] is "true")
        switch true
          when typeof obj[item[0]] is "undefined"
            obj[item[0]] = item[1]
          when (obj[item[0]] instanceof Array)
            obj[item[0]] = [obj[item[0]]]
          else
            obj[item[0]].push item[1]

    obj

  
  ###
  Returns an Array of parameters of a Function
  
  @method reflect
  @param  {Function} arg Function to reflect
  @return {Array}        Array of parameters
  ###
  reflect: (arg) ->
    arg = this  if typeof arg is "undefined"
    arg = $  if typeof arg is "undefined"
    arg = arg.toString().match(/function\s+\w*\s*\((.*?)\)/)[1]
    (if arg isnt "" then arg.explode() else [])

  
  ###
  Creates a recursive function
  
  Return false from the function to halt recursion
  
  @method repeat
  @param  {Function} fn  Function to execute repeatedly
  @param  {Number}   ms  Milliseconds to stagger the execution
  @param  {String}   id  [Optional] Timeout ID
  @return {String}       Timeout ID
  ###
  repeat: (fn, ms, id) ->
    ms = ms or 10
    id = id or utility.guid(true)
    recursive = (fn, ms, id) ->
      recursive = this
      if fn() isnt false
        utility.defer (->
          recursive.call recursive, fn, ms, id
        ), ms

    recursive.call recursive, fn, ms, id
    id

  
  ###
  Stops an Event from bubbling
  
  @param  {Object} e Event
  @return {Object}   Event
  ###
  stop: (e) ->
    e.cancelBubble = true  if typeof e.cancelBubble isnt "undefined"
    e.preventDefault()  if typeof e.preventDefault is "function"
    e.stopPropagation()  if typeof e.stopPropagation is "function"
    e

  
  ###
  Transforms JSON to HTML and appends to Body or target Element
  
  @method tpl
  @param  {Object} data   JSON Object describing HTML
  @param  {Mixed}  target [Optional] Target Element or Element.id to receive the HTML
  @return {Object}        New Element created from the template
  ###
  tpl: (arg, target) ->
    frag = undefined
    switch true
      when typeof arg isnt "object", not (/object|undefined/.test(typeof target)) and typeof (target = (if target.charAt(0) is "#" then $(target) else $(target)[0])) is "undefined"
        throw Error(label.error.invalidArguments)
    target = $("body")[0]  if typeof target is "undefined"
    frag = document.createDocumentFragment()
    switch true
      when arg instanceof Array
        arg.each (i, idx) ->
          element.create(array.cast(i, true)[0], frag).html array.cast(i)[0]

      else
        utility.iterate arg, (i, k) ->
          switch true
            when typeof i is "string"
              element.create(k, frag).html i
            when i instanceof Array, i instanceof Object
              utility.tpl i, element.create(k, frag)

    target.appendChild frag
    array.last target.childNodes

  
  ###
  Walks a structure and returns arg
  
  @method  walk
  @param  {Mixed}  obj  Object or Array
  @param  {String} arg  String describing the property to return
  @return {Mixed}       arg
  ###
  walk: (obj, arg) ->
    arg.replace(/\]$/, "").replace(/\]/g, ".").split(/\.|\[/).each (i) ->
      obj = obj[i]

    obj