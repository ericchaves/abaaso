###
Client properties and methods

@class client
@namespace abaaso
###
client =
  android: (->
    not server and /android/i.test(navigator.userAgent)
  )()
  blackberry: (->
    not server and /blackberry/i.test(navigator.userAgent)
  )()
  chrome: (->
    not server and /chrome/i.test(navigator.userAgent)
  )()
  firefox: (->
    not server and /firefox/i.test(navigator.userAgent)
  )()
  ie: (->
    not server and /msie/i.test(navigator.userAgent)
  )()
  ios: (->
    not server and /ipad|iphone/i.test(navigator.userAgent)
  )()
  linux: (->
    not server and /linux|bsd|unix/i.test(navigator.userAgent)
  )()
  mobile: (->
    abaaso.client.mobile = @mobile = not server and (/blackberry|iphone|webos/i.test(navigator.userAgent) or (/android/i.test(navigator.userAgent) and (abaaso.client.size.height < 720 or abaaso.client.size.width < 720)))
  )
  playbook: (->
    not server and /playbook/i.test(navigator.userAgent)
  )()
  opera: (->
    not server and /opera/i.test(navigator.userAgent)
  )()
  osx: (->
    not server and /macintosh/i.test(navigator.userAgent)
  )()
  safari: (->
    not server and /safari/i.test(navigator.userAgent.replace(/chrome.*/i, ""))
  )()
  tablet: (->
    abaaso.client.tablet = @tablet = not server and (/ipad|playbook|webos/i.test(navigator.userAgent) or (/android/i.test(navigator.userAgent) and (abaaso.client.size.width >= 720 or abaaso.client.size.width >= 720)))
  )
  webos: (->
    not server and /webos/i.test(navigator.userAgent)
  )()
  windows: (->
    not server and /windows/i.test(navigator.userAgent)
  )()
  version: (->
    version = 0
    switch true
      when @chrome
        version = navigator.userAgent.replace(/(.*chrome\/|safari.*)/g, "")
      when @firefox
        version = navigator.userAgent.replace(/(.*firefox\/)/g, "")
      when @ie
        version = parseInt(navigator.userAgent.replace(/(.*msie|;.*)/g, ""))
        version = document.documentMode  if document.documentMode < version
      when @opera
        version = navigator.userAgent.replace(/(.*opera\/|\(.*)/g, "")
      when @safari
        version = navigator.userAgent.replace(/(.*version\/|safari.*)/g, "")
      else
        version = (if (typeof navigator isnt "undefined") then navigator.appVersion else 0)
    version = (if not isNaN(parseInt(version)) then parseInt(version) else 0)
    abaaso.client.version = @version = version
    version
  )
  
  ###
  Quick way to see if a URI allows a specific command
  
  @method allows
  @param  {String} uri     URI to query
  @param  {String} command Command to query for
  @return {Boolean}        True if the command is allowed
  ###
  allows: (uri, command) ->
    throw Error(label.error.invalidArguments)  if uri.isEmpty() or command.isEmpty()
    return `undefined`  unless cache.get(uri, false)
    command = command.toLowerCase()
    result = undefined
    switch true
      when command is "delete"
        result = ((client.permissions(uri, command).bit & 1) is 0)
      when command is "get"
        result = ((client.permissions(uri, command).bit & 4) is 0)
      when (/post|put/.test(command))
        result = ((client.permissions(uri, command).bit & 2) is 0)
      else
        result = false
    result

  
  ###
  Gets bit value based on args
  
  1 --d delete
  2 -w- write
  3 -wd write and delete
  4 r-- read
  5 r-d read and delete
  6 rw- read and write
  7 rwd read, write and delete
  
  @method bit
  @param  {Array} args Array of commands the URI accepts
  @return {Number} To be set as a bit
  @private
  ###
  bit: (args) ->
    result = 0
    args.each (a) ->
      switch a.toLowerCase()
        when "get"
          result |= 4
        when "post", "put"
          result |= 2
        when "delete"
          result |= 1

    result

  
  ###
  Determines if a URI is a CORS end point
  
  @method cors
  @param  {String} uri  URI to parse
  @return {Boolean}     True if CORS
  ###
  cors: (uri) ->
    not server and uri.indexOf("//") > -1 and uri.indexOf("//" + location.host) is -1

  
  ###
  Caches the headers from the XHR response
  
  @method headers
  @param  {Object} xhr  XMLHttpRequest Object
  @param  {String} uri  URI to request
  @param  {String} type Type of request
  @return {Object}      Cached URI representation
  @private
  ###
  headers: (xhr, uri, type) ->
    headers = String(xhr.getAllResponseHeaders()).split("\n")
    items = {}
    o = {}
    allow = null
    expires = new Date()
    header = undefined
    value = undefined
    headers.each (h) ->
      unless h.isEmpty()
        header = h.toString()
        value = header.substr((header.indexOf(":") + 1), header.length).replace(/\s/, "")
        header = header.substr(0, header.indexOf(":")).replace(/\s/, "")
        header = (->
          x = []
          header.explode("-").each (i) ->
            x.push i.capitalize()

          x.join "-"
        )()
        items[header] = value
        allow = value  if /allow|access-control-allow-methods/i.test(header)

    switch true
      when typeof items["Cache-Control"] isnt "undefined" and /no/.test(items["Cache-Control"]), typeof items["Pragma"] isnt "undefined" and /no/.test(items["Pragma"]), typeof items["Cache-Control"] isnt "undefined" and /\d/.test(items["Cache-Control"])
        expires = expires.setSeconds(expires.getSeconds() + parseInt(/\d{1,}/.exec(items["Cache-Control"])[0]))
      when typeof items["Expires"] isnt "undefined"
        expires = new Date(items["Expires"])
      else
        expires = expires.setSeconds(expires.getSeconds() + $.expires)
    o.expires = expires
    o.headers = items
    o.permission = client.bit((if allow isnt null then allow.explode() else [type]))
    if type isnt "head"
      cache.set uri, "expires", o.expires
      cache.set uri, "headers", o.headers
      cache.set uri, "permission", o.permission
    o

  
  ###
  Parses an XHR response
  
  @param  {Object} xhr  XHR Object
  @param  {String} type [Optional] Content-Type header value
  @return {Mixed}       Array, Boolean, Document, Number, Object or String
  ###
  parse: (xhr, type) ->
    type = type or ""
    result = undefined
    obj = undefined
    switch true
      when (/json|plain|javascript/.test(type) or type.isEmpty()) and Boolean(obj = json.decode(/[\{\[].*[\}\]]/.exec(xhr.responseText), true))
        result = obj
      when (/xml/.test(type) and String(xhr.responseText).isEmpty() and xhr.responseXML isnt null)
        result = xml.decode((if typeof xhr.responseXML.xml isnt "undefined" then xhr.responseXML.xml else xhr.responseXML))
      when (/<[^>]+>[^<]*]+>/.test(xhr.responseText))
        result = xml.decode(xhr.responseText)
      else
        result = xhr.responseText
    result

  
  ###
  Returns the permission of the cached URI
  
  @method permissions
  @param  {String} uri URI to query
  @return {Object}     Contains an Array of available commands, the permission bit and a map
  ###
  permissions: (uri) ->
    cached = cache.get(uri, false)
    bit = (if not cached then 0 else cached.permission)
    result =
      allows: []
      bit: bit
      map:
        read: 4
        write: 2
        delete: 1

    result.allows.push "DELETE"  if bit & 1
    if bit & 2
      (->
        result.allows.push "POST"
        result.allows.push "PUT"
      )()
    result.allows.push "GET"  if bit & 4
    result

  
  ###
  Creates a JSONP request
  
  Events: beforeJSONP     Fires before the SCRIPT is made
  afterJSONP      Fires after the SCRIPT is received
  failedJSONP     Fires on error
  timeoutJSONP    Fires 30s after SCRIPT is made
  
  @method jsonp
  @param  {String}   uri     URI to request
  @param  {Function} success A handler function to execute when an appropriate response been received
  @param  {Function} failure [Optional] A handler function to execute on error
  @param  {Mixed}    args    Custom JSONP handler parameter name, default is "callback"; or custom headers for GET request (CORS)
  @return {String}           URI to query
  ###
  jsonp: (uri, success, failure, args) ->
    curi = uri
    guid = utility.guid(true)
    callback = undefined
    cbid = undefined
    s = undefined
    
    # Utilizing the sugar if namespace is not global
    if typeof external is "undefined"
      utility.define "abaaso.callback", {}, global  if typeof global.abaaso is "undefined"
      external = "abaaso"
    switch true
      when typeof args is "undefined", args is null, args instanceof Object and (args.callback is null or typeof args.callback is "undefined"), typeof args is "string" and args.isEmpty()
        callback = "callback"
      when args instanceof Object and typeof args.callback isnt "undefined"
        callback = args.callback
      else
        callback = "callback"
    curi = curi.replace(callback + "=?", "")
    curi.once("afterJSONP", (arg) ->
      @un "failedJSONP", guid
      success arg  if typeof success is "function"
    , guid).once "failedJSONP", (->
      @un "failedJSONP", guid
      failure()  if typeof failure is "function"
    ), guid
    loop
      cbid = utility.genId().slice(0, 10)
      break unless typeof global.abaaso.callback[cbid] isnt "undefined"
    uri = uri.replace(callback + "=?", callback + "=" + external + ".callback." + cbid)
    global.abaaso.callback[cbid] = (arg) ->
      s.destroy()
      clearTimeout utility.timer[cbid]
      delete utility.timer[cbid]

      delete global.abaaso.callback[cbid]

      curi.fire "afterJSONP", arg

    s = $("head")[0].create("script",
      src: uri
      type: "text/javascript"
    )
    utility.defer (->
      curi.fire "failedJSONP"
    ), 30000, cbid
    uri

  
  ###
  Creates an XmlHttpRequest to a URI (aliased to multiple methods)
  
  Events: beforeXHR             Fires before the XmlHttpRequest is made
  before[type]          Fires before the XmlHttpRequest is made, type specific
  failed[type]          Fires on error
  progress[type]        Fires on progress
  progressUpload[type]  Fires on upload progress
  received[type]        Fires on XHR readystate 2
  timeout[type]         Fires 30s after XmlHttpRequest is made
  
  @method request
  @param  {String}   uri     URI to query
  @param  {String}   type    Type of request (DELETE/GET/POST/PUT/HEAD)
  @param  {Function} success A handler function to execute when an appropriate response been received
  @param  {Function} failure [Optional] A handler function to execute on error
  @param  {Mixed}    args    Data to send with the request
  @param  {Object}   headers Custom request headers (can be used to set withCredentials)
  @return {String}           URI to query
  @private
  ###
  request: (uri, type, success, failure, args, headers) ->
    cors = undefined
    xhr = undefined
    payload = undefined
    cached = undefined
    typed = undefined
    guid = undefined
    contentType = undefined
    doc = undefined
    ab = undefined
    blob = undefined
    throw Error(label.error.invalidArguments)  if /post|put/i.test(type) and typeof args is "undefined"
    type = type.toLowerCase()
    headers = (if headers instanceof Object then headers else null)
    cors = client.cors(uri)
    xhr = (if (client.ie and client.version < 10 and cors) then new XDomainRequest() else new XMLHttpRequest())
    payload = (if /post|put/i.test(type) and typeof args isnt "undefined" then args else null)
    cached = (if type is "get" then cache.get(uri) else false)
    typed = type.capitalize()
    guid = utility.guid(true)
    contentType = null
    doc = (typeof Document isnt "undefined")
    ab = (typeof ArrayBuffer isnt "undefined")
    blob = (typeof Blob isnt "undefined")
    if type is "delete"
      uri.once "afterDelete", ->
        cache.expire this

    uri.once("after" + typed, (arg) ->
      uri.un "failed" + typed, guid
      success arg  if typeof success is "function"
    , guid).once("failed" + typed, (arg) ->
      uri.un "after" + typed, guid
      failure arg  if typeof failure is "function"
    , guid).fire "before" + typed
    return uri.fire("failed" + typed)  if type isnt "head" and uri.allows(type) is false
    unless type is "get" and Boolean(cached)
      xhr[(if xhr instanceof XMLHttpRequest then "onreadystatechange" else "onload")] = ->
        client.response xhr, uri, type

      
      # Setting events
      if typeof xhr.ontimeout isnt "undefined"
        xhr.ontimeout = (e) ->
          uri.fire "timeout" + typed, e
      if typeof xhr.onprogress isnt "undefined"
        xhr.onprogress = (e) ->
          uri.fire "progress" + typed, e
      if typeof xhr.upload isnt "undefined" and typeof xhr.upload.onprogress isnt "undefined"
        xhr.upload.onprogress = (e) ->
          uri.fire "progressUpload" + typed, e
      try
        xhr.open type.toUpperCase(), uri, true
        
        # Setting Content-Type value
        contentType = headers["Content-Type"]  if headers isnt null and headers.hasOwnProperty("Content-Type")
        contentType = "text/plain"  if cors and contentType is null
        
        # Transforming payload
        if payload isnt null
          payload = payload.xml  if payload.hasOwnProperty("xml")
          payload = xml.decode(payload)  if doc and payload instanceof Document
          contentType = "application/xml"  if typeof payload is "string" and /<[^>]+>[^<]*]+>/.test(payload)
          if not (ab and payload instanceof ArrayBuffer) and not (blob and payload instanceof Blob) and payload instanceof Object
            contentType = "application/json"
            payload = json.encode(payload)
          contentType = "application/octet-stream"  if contentType is null and ((ab and payload instanceof ArrayBuffer) or (blob and payload instanceof Blob))
          contentType = "application/x-www-form-urlencoded; charset=UTF-8"  if contentType is null
        
        # Setting headers
        if typeof xhr.setRequestHeader isnt "undefined"
          xhr.setRequestHeader "ETag", cached.headers.ETag  if typeof cached is "object" and cached.headers.hasOwnProperty("ETag")
          headers = {}  if headers is null
          headers["Content-Type"] = contentType  if contentType isnt null
          delete headers.callback  if headers.hasOwnProperty("callback")
          utility.iterate headers, (v, k) ->
            xhr.setRequestHeader k, v  if v isnt null and k isnt "withCredentials"

        
        # Cross Origin Resource Sharing (CORS)
        xhr.withCredentials = headers.withCredentials  if typeof xhr.withCredentials is "boolean" and headers isnt null and typeof headers.withCredentials is "boolean"
        
        # Firing event & sending request
        uri.fire "beforeXHR",
          xhr: xhr
          uri: uri

        (if payload isnt null then xhr.send(payload) else xhr.send())
      catch e
        error e, arguments_, this, true
        uri.fire "failed" + typed,
          response: client.parse(xhr)
          xhr: xhr

    uri

  
  ###
  Caches the URI headers & response if received, and fires the relevant events
  
  If abaaso.state.header is set, an application state change is possible
  
  Permissions are handled if the ACCEPT header is received; a bit is set on the cached
  resource
  
  Events: afterXHR     Fires after the XmlHttpRequest response is received
  after[type]  Fires after the XmlHttpRequest response is received, type specific
  reset        Fires if a 206 response is received
  moved        Fires if a 301 response is received
  success      Fires if a 400 response is received
  failure      Fires if an exception is thrown
  
  @method response
  @param  {Object} xhr  XMLHttpRequest Object
  @param  {String} uri  URI to query
  @param  {String} type Type of request
  @return {String} uri  URI to query
  @private
  ###
  response: (xhr, uri, type) ->
    typed = type.toLowerCase().capitalize()
    l = location
    state = null
    s = undefined
    o = undefined
    cors = undefined
    r = undefined
    t = undefined
    switch true
      when xhr.readyState is 2
        uri.fire "received" + typed
      when xhr.readyState is 4
        uri.fire "afterXHR",
          xhr: xhr
          uri: uri

        try
          switch xhr.status
            when 200, 201, 202, 203, 204, 205, 206, 301
              s = abaaso.state
              o = client.headers(xhr, uri, type)
              cors = client.cors(uri)
              switch true
                when type is "head"
                  return uri.fire("afterHead", o.headers)
                when type isnt "delete" and /200|201/.test(xhr.status)
                  t = (if typeof o.headers["Content-Type"] isnt "undefined" then o.headers["Content-Type"] else "")
                  r = client.parse(xhr, t)
                  throw Error(label.error.serverError)  if typeof r is "undefined"
                  cache.set uri, "response", (o.response = utility.clone(r))
              
              # Application state change triggered by hypermedia (HATEOAS)
              (if typeof s.change is "function" then s.change(state) else s.current = state)  if s.header isnt null and Boolean(state = o.headers[s.header]) and s.current isnt state
              switch xhr.status
                when 200, 201
                  uri.fire "after" + typed, r
                when 202, 203, 204, 206
                  uri.fire "after" + typed
                when 205
                  uri.fire "reset"
                when 301
                  uri.fire "moved", r
            when 401
              throw Error(label.error.serverUnauthorized)
            when 403
              cache.set uri, "!permission", client.bit([type])
              throw Error(label.error.serverForbidden)
            when 405
              cache.set uri, "!permission", client.bit([type])
              throw Error(label.error.serverInvalidMethod)
            when 0
            else
              throw Error(label.error.serverError)
        catch e
          error e, arguments_, this, true
          uri.fire "failed" + typed,
            response: client.parse(xhr)
            xhr: xhr

      when client.ie and client.cors(uri) # XDomainRequest
        r = undefined
        x = undefined
        switch true
          when Boolean(x = json.decode(/[\{\[].*[\}\]]/.exec(xhr.responseText)))
            r = x
          when (/<[^>]+>[^<]*]+>/.test(xhr.responseText))
            r = xml.decode(xhr.responseText)
          else
            r = xhr.responseText
        cache.set uri, "permission", client.bit(["get"])
        cache.set uri, "response", r
        uri.fire "afterGet", r
    uri

  
  ###
  Returns the visible area of the View
  
  @method size
  @return {Object} Describes the View {x: ?, y: ?}
  ###
  size: ->
    view = (if not server then ((if typeof document.documentElement isnt "undefined" then document.documentElement else document.body)) else
      clientHeight: 0
      clientWidth: 0
    )
    height: view.clientHeight
    width: view.clientWidth