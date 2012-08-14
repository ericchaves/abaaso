((global) ->
  document = global.document
  location = global.location
  navigator = global.navigator
  server = typeof document is "undefined"
  abaaso = undefined
  http = undefined
  https = undefined
  if server
    http = require("http")
    https = require("https")
    localStorage = require("localStorage")  if typeof Storage is "undefined"
    XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest  if typeof XMLHttpRequest is "undefined"
  abaaso = global.abaaso or (->
    "use strict"
    $ = undefined
    bootstrap = undefined
    error = undefined
    external = undefined
    
    #{{CORE}}
    
    #{{BOOTSTRAP}}
    
    # @constructor
    
    # Classes
    array: array
    callback: {}
    client:
      
      # Properties
      android: client.android
      blackberry: client.blackberry
      chrome: client.chrome
      firefox: client.firefox
      ie: client.ie
      ios: client.ios
      linux: client.linux
      mobile: client.mobile
      opera: client.opera
      osx: client.osx
      playbook: client.playbook
      safari: client.safari
      tablet: client.tablet
      size:
        height: 0
        width: 0

      version: 0
      webos: client.webos
      windows: client.windows
      
      # Methods
      del: (uri, success, failure, headers) ->
        client.request uri, "DELETE", success, failure, null, headers

      get: (uri, success, failure, headers) ->
        client.request uri, "GET", success, failure, null, headers

      headers: (uri, success, failure) ->
        client.request uri, "HEAD", success, failure

      post: (uri, success, failure, args, headers) ->
        client.request uri, "POST", success, failure, args, headers

      put: (uri, success, failure, args, headers) ->
        client.request uri, "PUT", success, failure, args, headers

      jsonp: (uri, success, failure, callback) ->
        client.jsonp uri, success, failure, callback

      options: (uri, success, failure) ->
        client.request uri, "OPTIONS", success, failure

      permissions: client.permissions

    cookie: cookie
    data: data
    element: element
    json: json
    label: label
    loading:
      create: utility.loading
      url: null

    message: message
    mouse: mouse
    number: number
    observer:
      log: observer.log
      add: observer.add
      fire: observer.fire
      list: observer.list
      once: observer.once
      remove: observer.remove

    state:
      _current: null
      header: null
      previous: null

    string: string
    validate: validate
    xml: xml
    
    # Methods & Properties
    $: utility.$
    alias: utility.alias
    aliased: "$"
    allows: client.allows
    append: (type, args, obj) ->
      obj.genId()  if obj instanceof Element
      element.create type, args, obj, "last"

    bootstrap: bootstrap
    clear: element.clear
    clone: utility.clone
    coerce: utility.coerce
    compile: utility.compile
    create: element.create
    css: element.css
    decode: json.decode
    defer: utility.defer
    define: utility.define
    del: (uri, success, failure, headers) ->
      client.request uri, "DELETE", success, failure, null, headers

    destroy: element.destroy
    encode: json.encode
    error: utility.error
    expire: cache.clean
    expires: 120000
    extend: utility.extend
    fire: (obj, event, arg) ->
      all = typeof arg isnt "undefined"
      o = undefined
      e = undefined
      a = undefined
      o = (if all then obj else this)
      e = (if all then event else obj)
      a = (if all then arg else event)
      o = abaaso  if typeof o is "undefined" or o is $
      observer.fire o, e, a

    genId: utility.genId
    get: (uri, success, failure, headers) ->
      client.request uri, "GET", success, failure, null, headers

    guid: utility.guid
    headers: (uri, success, failure) ->
      client.request uri, "HEAD", success, failure

    hidden: element.hidden
    id: "abaaso"
    init: ->
      
      # Stopping multiple executions
      delete abaaso.init

      
      # Firing events to setup
      $.fire("init").un("init").fire("ready").un "ready"

    iterate: utility.iterate
    jsonp: (uri, success, failure, callback) ->
      client.jsonp uri, success, failure, callback

    listeners: (event) ->
      obj = this
      obj = abaaso  if typeof obj is "undefined" or obj is $
      observer.list obj, event

    log: utility.log
    merge: utility.merge
    module: utility.module
    object: utility.object
    on: (obj, event, listener, id, scope, state) ->
      all = typeof listener is "function"
      o = undefined
      e = undefined
      l = undefined
      i = undefined
      s = undefined
      st = undefined
      o = (if all then obj else this)
      e = (if all then event else obj)
      l = (if all then listener else event)
      i = (if all then id else listener)
      s = (if all then scope else id)
      st = (if all then state else scope)
      o = abaaso  if typeof o is "undefined" or o is $
      s = o  if typeof s is "undefined"
      observer.add o, e, l, i, s, st

    once: (obj, event, listener, id, scope, state) ->
      all = typeof listener is "function"
      o = undefined
      e = undefined
      l = undefined
      i = undefined
      s = undefined
      st = undefined
      o = (if all then obj else this)
      e = (if all then event else obj)
      l = (if all then listener else event)
      i = (if all then id else listener)
      s = (if all then scope else id)
      st = (if all then state else scope)
      o = abaaso  if typeof o is "undefined" or o is $
      s = o  if typeof s is "undefined"
      observer.once o, e, l, i, s, st

    options: (uri, success, failure) ->
      client.request uri, "OPTIONS", success, failure

    permissions: client.permissions
    position: element.position
    post: (uri, success, failure, args, headers) ->
      client.request uri, "POST", success, failure, args, headers

    prepend: (type, args, obj) ->
      obj.genId()  if obj instanceof Element
      element.create type, args, obj, "first"

    property: utility.property
    put: (uri, success, failure, args, headers) ->
      client.request uri, "PUT", success, failure, args, headers

    queryString: utility.queryString
    ready: false
    reflect: utility.reflect
    repeat: utility.repeat
    route:
      enabled: false
      del: route.del
      hash: route.hash
      init: route.init
      list: route.list
      load: route.load
      server: route.server
      set: route.set

    stylesheet: (arg, media) ->
      element.create "link",
        rel: "stylesheet"
        type: "text/css"
        href: arg
        media: media or "print, screen"
      , $("head")[0]

    script: (arg, target, pos) ->
      element.create "script",
        type: "application/javascript"
        src: arg
      , target or $("head")[0], pos

    stop: utility.stop
    store: (arg, args) ->
      data.register.call data, arg, args

    tpl: utility.tpl
    un: (obj, event, id, state) ->
      all = typeof id isnt "undefined"
      o = undefined
      e = undefined
      i = undefined
      s = undefined
      o = (if all then obj else this)
      e = (if all then event else obj)
      i = (if all then id else event)
      s = (if all then state else id)
      o = abaaso  if typeof o is "undefined" or o is $
      observer.remove o, e, i, s

    update: element.update
    version: "{{VERSION}}"
    walk: utility.walk
  )()
  
  # Conditional bootstrap incase of multiple loading
  abaaso.bootstrap()  if typeof abaaso.bootstrap is "function"
  
  # Node, AMD & window supported
  switch true
    when typeof exports isnt "undefined"
      module.exports = abaaso
    when typeof define is "function"
      define ->
        abaaso

    else
      global.abaaso = abaaso
) this