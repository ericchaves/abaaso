###
Element methods

@class element
@namespace abaaso
###
element =
  
  ###
  Gets or sets attributes of Element
  
  @param  {Mixed}  obj   Element or $ query
  @param  {String} name  Attribute name
  @param  {Mixed}  value Attribute value
  @return {Object}       Element
  ###
  attr: (obj, key, value) ->
    value = value.trim()  if typeof value is "string"
    regex = /checked|disabled/
    target = undefined
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  if (obj not instanceof Element) or typeof key is "undefined" or String(key).isEmpty()
    switch true
      when regex.test(key) and typeof value is "undefined"
        obj[key]
      when regex.test(key) and typeof value isnt "undefined"
        obj[key] = value
        obj
      when obj.nodeName is "SELECT" and key is "selected" and typeof value is "undefined"
        $("#" + obj.id + " option[selected=\"selected\"]").first() or $("#" + obj.id + " option").first()
      when obj.nodeName is "SELECT" and key is "selected" and typeof value isnt "undefined"
        target = $("#" + obj.id + " option[selected=\"selected\"]").first()
        if typeof target isnt "undefined"
          target.selected = false
          target.removeAttribute "selected"
        target = $("#" + obj.id + " option[value=\"" + value + "\"]").first()
        target.selected = true
        target.setAttribute "selected", "selected"
        obj
      when typeof value is "undefined"
        obj.getAttribute key
      when value is null
        obj.removeAttribute key
        obj
      else
        obj.setAttribute key, value
        obj

  
  ###
  Clears an object's innerHTML, or resets it's state
  
  Events: beforeClear  Fires before the Object is cleared
  afterClear   Fires after the Object is cleared
  
  @method clear
  @param  {Mixed} obj Element or $ query
  @return {Object}    Element
  ###
  clear: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    obj.fire "beforeClear"
    switch true
      when typeof obj.reset is "function"
        obj.reset()
      when typeof obj.value isnt "undefined"
        obj.update
          innerHTML: ""
          value: ""

      else
        obj.update innerHTML: ""
    obj.fire "afterClear"
    obj

  
  ###
  Creates an Element in document.body or a target Element
  
  An id is generated if not specified with args
  
  Events: beforeCreate  Fires before the Element has been created, but not set
  afterCreate   Fires after the Element has been appended to it's parent
  
  @method create
  @param  {String} type   Type of Element to create
  @param  {Object} args   [Optional] Collection of properties to apply to the new element
  @param  {Mixed}  target [Optional] Target object or element.id value to append to
  @param  {Mixed}  pos    [Optional] "first", "last" or Object describing how to add the new Element, e.g. {before: referenceElement}
  @return {Object}        Element that was created or undefined
  ###
  create: (type, args, target, pos) ->
    throw Error(label.error.invalidArguments)  if typeof type is "undefined" or String(type).isEmpty()
    obj = undefined
    uid = undefined
    frag = undefined
    switch true
      when typeof target isnt "undefined"
        target = utility.object(target)
      when typeof args isnt "undefined" and (typeof args is "string" or typeof args.childNodes isnt "undefined")
        target = utility.object(args)
      else
        target = document.body
    throw Error(label.error.invalidArguments)  if typeof target is "undefined"
    frag = (target not instanceof Element)
    uid = (if typeof args isnt "undefined" and typeof args isnt "string" and typeof args.childNodes is "undefined" and typeof args.id isnt "undefined" and typeof $("#" + args.id) is "undefined" then args.id else utility.genId())
    delete args.id  if typeof args isnt "undefined" and typeof args.id isnt "undefined"
    $.fire "beforeCreate", uid
    unless frag
      target.fire "beforeCreate", uid
    else target.parentNode.fire "beforeCreate", uid  if frag and target.parentNode isnt null
    obj = document.createElement(type)
    obj.id = uid
    obj.update args  if typeof args is "object" and typeof args.childNodes is "undefined"
    switch true
      when typeof pos is "undefined", pos is "last"
        target.appendChild obj
      when pos is "first"
        target.prependChild obj
      when pos is "after"
        pos = {}
        pos.after = target
        target = target.parentNode
      when typeof pos.after isnt "undefined"
        target.insertBefore obj, pos.after.nextSibling
      when pos is "before"
        pos = {}
        pos.before = target
        target = target.parentNode
      when typeof pos.before isnt "undefined"
        target.insertBefore obj, pos.before
      else
        target.appendChild obj
    unless frag
      target.fire "afterCreate", obj
    else target.parentNode.fire "afterCreate", obj  if frag and target.parentNode isnt null
    $.fire "afterCreate", obj
    obj

  
  ###
  Creates a CSS stylesheet in the View
  
  @method css
  @param  {String} content CSS to put in a style tag
  @return {Object}         Element created or undefined
  ###
  css: (content) ->
    ss = undefined
    css = undefined
    ss = $("head").first().create("style",
      type: "text/css"
    )
    unless ss.styleSheet
      css = document.createTextNode(content)
      ss.appendChild css
    ss

  
  ###
  Data attribute facade acting as a getter (with coercion) & setter
  
  @method  data
  @param  {Mixed}  obj   Element or Array of Elements or $ queries
  @param  {String} key   Data key
  @param  {Mixed}  value Boolean, Number or String to set
  @return {Mixed}        undefined, Element or value
  ###
  data: (obj, key, value) ->
    result = undefined
    if typeof value isnt "undefined"
      (if typeof obj.dataset is "object" then obj.dataset[key] = value else element.attr(obj, "data-" + key, value))
      result = obj
    else
      result = utility.coerce((if typeof obj.dataset is "object" then obj.dataset[key] else element.attr(obj, "data-" + key)))
    result

  
  ###
  Destroys an Element
  
  Events: beforeDestroy  Fires before the destroy starts
  afterDestroy   Fires after the destroy ends
  
  @method destroy
  @param  {Mixed} obj Element or $ query
  @return {Undefined} undefined
  ###
  destroy: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    $.fire "beforeDestroy", obj
    obj.fire "beforeDestroy"
    observer.remove obj.id
    obj.parentNode.removeChild obj  if obj.parentNode isnt null
    obj.fire "afterDestroy"
    $.fire "afterDestroy", obj.id
    `undefined`

  
  ###
  Disables an Element
  
  Events: beforeDisable  Fires before the disable starts
  afterDisable   Fires after the disable ends
  
  @method disable
  @param  {Mixed} obj Element or $ query
  @return {Object}    Element
  ###
  disable: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    if typeof obj.disabled is "boolean" and not obj.disabled
      obj.fire "beforeDisable"
      obj.disabled = true
      obj.fire "afterDisable"
    obj

  
  ###
  Enables an Element
  
  Events: beforeEnable  Fires before the enable starts
  afterEnable   Fires after the enable ends
  
  @method enable
  @param  {Mixed} obj Element or $ query
  @return {Object}    Element
  ###
  enable: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    if typeof obj.disabled is "boolean" and obj.disabled
      obj.fire "beforeEnable"
      obj.disabled = false
      obj.fire "afterEnable"
    obj

  
  ###
  Finds descendant childNodes of Element matched by arg
  
  @method find
  @param  {Mixed}  obj Element to search
  @param  {String} arg Comma delimited string of descendant selectors
  @return {Mixed}      Array of Elements or undefined
  ###
  find: (obj, arg) ->
    result = []
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  if (obj not instanceof Element) or typeof arg isnt "string"
    utility.genId obj
    arg.explode().each (i) ->
      $("#" + obj.id + " " + i).each (o) ->
        result.add o


    result

  
  ###
  Determines if Element has descendants matching arg
  
  @method has
  @param  {Mixed}   obj Element or Array of Elements or $ queries
  @param  {String}  arg Type of Element to find
  @return {Boolean}     True if 1 or more Elements are found
  ###
  has: (obj, arg) ->
    result = element.find(obj, arg)
    not isNaN(result.length) and result.length > 0

  
  ###
  Determines if obj has a specific CSS class
  
  @method hasClass
  @param  {Mixed} obj Element or $ query
  @return {Mixed}     Element, Array of Elements or undefined
  ###
  hasClass: (obj, klass) ->
    obj = utility.object(obj)
    obj.classList.contains klass

  
  ###
  Hides an Element if it's visible
  
  Events: beforeHide  Fires before the object is hidden
  afterHide   Fires after the object is hidden
  
  @method hide
  @param  {Mixed} obj Element or $ query
  @return {Object}    Element
  ###
  hide: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    obj.fire "beforeHide"
    switch true
      when typeof obj.hidden is "boolean"
        obj.hidden = true
      else
        obj["data-display"] = obj.style.display
        obj.style.display = "none"
    obj.fire "afterHide"
    obj

  
  ###
  Returns a Boolean indidcating if the Object is hidden
  
  @method hidden
  @param  {Mixed} obj Element or $ query
  @return {Boolean}   True if hidden
  ###
  hidden: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    obj.style.display is "none" or (typeof obj.hidden is "boolean" and obj.hidden)

  
  ###
  Determines if Element is equal to arg, supports nodeNames & CSS2+ selectors
  
  @method is
  @param  {Mixed}   obj Element or $ query
  @param  {String}  arg Property to query
  @return {Boolean}     True if a match
  ###
  is: (obj, arg) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  if (obj not instanceof Element) or typeof arg isnt "string"
    utility.genId obj
    (if /^:/.test(arg) then (element.find(obj.parentNode, obj.nodeName.toLowerCase() + arg).contains(obj)) else new RegExp(arg, "i").test(obj.nodeName))

  
  ###
  Adds or removes a CSS class
  
  Events: beforeClassChange  Fires before the Object's class is changed
  afterClassChange   Fires after the Object's class is changed
  
  @method clear
  @param  {Mixed}   obj Element or $ query
  @param  {String}  arg Class to add or remove (can be a wildcard)
  @param  {Boolean} add Boolean to add or remove, defaults to true
  @return {Object}      Element
  ###
  klass: (obj, arg, add) ->
    classes = undefined
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  if (obj not instanceof Element) or String(arg).isEmpty()
    obj.fire "beforeClassChange"
    add = (add isnt false)
    arg = arg.explode(" ")
    if add
      arg.each (i) ->
        obj.classList.add i

    else
      arg.each (i) ->
        unless i isnt "*"
          obj.classList.each (x) ->
            @remove x

          false

    obj.fire "afterClassChange"
    obj

  
  ###
  Finds the position of an element
  
  @method position
  @param  {Mixed} obj Element or $ query
  @return {Object}    Object {top: n, right: n, bottom: n, left: n}
  ###
  position: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    left = undefined
    top = undefined
    height = undefined
    width = undefined
    left = top = 0
    width = obj.offsetWidth
    height = obj.offsetHeight
    if obj.offsetParent
      top = obj.offsetTop
      left = obj.offsetLeft
      while obj = obj.offsetParent
        left += obj.offsetLeft
        top += obj.offsetTop
    top: top
    right: document.documentElement.clientWidth - (left + width)
    bottom: document.documentElement.clientHeight + global.scrollY - (top + height)
    left: left

  
  ###
  Prepends an Element to an Element
  
  @method prependChild
  @param  {Object} obj   Element or $ query
  @param  {Object} child Child Element
  @return {Object}       Element
  ###
  prependChild: (obj, child) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  if (obj not instanceof Element) or (child not instanceof Element)
    (if obj.childNodes.length is 0 then obj.appendChild(child) else obj.insertBefore(child, obj.childNodes[0]))

  
  ###
  Shows an Element if it's not visible
  
  Events: beforeEnable  Fires before the object is visible
  afterEnable   Fires after the object is visible
  
  @method show
  @param  {Mixed} obj Element or $ query
  @return {Object}    Element
  ###
  show: (obj) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    obj.fire "beforeShow"
    switch true
      when typeof obj.hidden is "boolean"
        obj.hidden = false
      else
        obj.style.display = (if obj.getAttribute("data-display") isnt null then obj.getAttribute("data-display") else "inherit")
    obj.fire "afterShow"
    obj

  
  ###
  Returns the size of the Object
  
  @method size
  @param  {Mixed} obj Element or $ query
  @return {Object}    Size {height: n, width:n}
  ###
  size: (obj) ->
    obj = utility.object(obj)
    num = undefined
    height = undefined
    width = undefined
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    
    ###
    Casts n to a number or returns zero
    
    @param  {Mixed} n The value to cast
    @return {Number}  The casted value or zero
    ###
    num = (n) ->
      (if not isNaN(parseInt(n)) then parseInt(n) else 0)

    height = obj.offsetHeight + num(obj.style.paddingTop) + num(obj.style.paddingBottom) + num(obj.style.borderTop) + num(obj.style.borderBottom)
    width = obj.offsetWidth + num(obj.style.paddingLeft) + num(obj.style.paddingRight) + num(obj.style.borderLeft) + num(obj.style.borderRight)
    height: height
    width: width

  
  ###
  Getter / setter for an Element's text
  
  @param  {Object} obj Element or $ query
  @param  {String} arg [Optional] Value to set
  @return {Object}     Element
  ###
  text: (obj, arg) ->
    obj = utility.object(obj)
    key = (if typeof obj.textContent isnt "undefined" then "textContent" else "innerText")
    payload = {}
    set = false
    if typeof arg isnt "undefined"
      set = true
      payload[key] = arg
    (if set then element.update(obj, payload) else obj[key])

  
  ###
  Toggles a CSS class
  
  @param  {Object} obj Element, or $ query
  @param  {String} arg CSS class to toggle
  @return {Object}     Element
  ###
  toggleClass: (obj, arg) ->
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    obj.classList.toggle arg
    obj

  
  ###
  Updates an Element
  
  Events: beforeUpdate  Fires before the update starts
  afterUpdate   Fires after the update ends
  
  @method update
  @param  {Mixed}  obj  Element or $ query
  @param  {Object} args Collection of properties
  @return {Object}      Element
  ###
  update: (obj, args) ->
    obj = utility.object(obj)
    args = args or {}
    regex = undefined
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    obj.fire "beforeUpdate"
    regex = /innerHTML|innerText|textContent|type|src/
    utility.iterate args, (v, k) ->
      switch true
        when regex.test(k)
          obj[k] = v
        when k is "class"
          (if not v.isEmpty() then obj.addClass(v) else obj.removeClass("*"))
        when k.indexOf("data-") is 0
          element.data obj, k.replace("data-", ""), v
        when "id"
          o = observer.listeners
          if typeof o[obj.id] isnt "undefined"
            o[k] = utility.clone(o[obj.id])
            delete o[obj.id]
        else
          obj.attr k, v

    obj.fire "afterUpdate"
    obj

  
  ###
  Gets or sets the value of Element
  
  Events: beforeValue  Fires before the object receives a new value
  afterValue   Fires after the object receives a new value
  
  @param  {Mixed}  obj   Element or $ query
  @param  {Mixed}  value [Optional] Value to set
  @return {Object}       Element
  ###
  val: (obj, value) ->
    output = null
    items = undefined
    obj = utility.object(obj)
    throw Error(label.error.invalidArguments)  unless obj instanceof Element
    switch true
      when typeof value is "undefined"
        switch true
          when (/radio|checkbox/g.test(obj.type))
            throw Error(label.error.expectedProperty)  if obj.name.isEmpty()
            items = $("input[name='" + obj.name + "']")
            items.each (i) ->
              return  if output isnt null
              output = i.value  if i.checked

          when (/select/g.test(obj.type))
            output = obj.options[obj.selectedIndex].value
          else
            output = (if typeof obj.value isnt "undefined" then obj.value else element.text(obj))
      else
        value = String(value)
        obj.fire "beforeValue"
        switch true
          when (/radio|checkbox/g.test(obj.type))
            items = $("input[name='" + obj.name + "']")
            items.each (i) ->
              return  if output isnt null
              if i.value is value
                i.checked = true
                output = i

          when (/select/g.test(obj.type))
            array.cast(obj.options).each (i) ->
              return  if output isnt null
              if i.value is value
                i.selected = true
                output = i

          else
            (if typeof obj.value isnt "undefined" then obj.value = value else element.text(obj, value))
        obj.fire "afterValue"
        output = obj
    output