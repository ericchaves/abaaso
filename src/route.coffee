###
URI routing

Client side routes will be in routes.all

@class route
@namespace abaaso
###
route =
  bang: /\#|\!\//g
  regex: new RegExp()
  
  # Routing listeners
  routes:
    all:
      error: ->
        unless server
          utility.error label.error.invalidRoute
          route.hash abaaso.route.initial  if abaaso.route.initial isnt null
        else
          throw Error(label.error.invalidRoute)

    del: {}
    get: {}
    put: {}
    post: {}

  
  ###
  Determines which HTTP method to use
  
  @param  {String} arg HTTP method
  @return {[type]}     HTTP method to utilize
  ###
  method: (arg) ->
    (if /all|del|get|put|post/g.test(arg) then arg.toLowerCase() else "all")

  
  ###
  Deletes a route
  
  @method del
  @param  {String} name  Route name
  @param  {String} verb  HTTP method
  @return {Mixed}        True or undefined
  ###
  del: (name, verb) ->
    verb = route.method(verb)
    error = (name is "error")
    if (error and verb isnt "all") or (not error and route.routes[verb].hasOwnProperty(name))
      abaaso.route.initial = null  if abaaso.route.initial is name
      delete route.routes[verb][name]
    else
      throw Error(label.error.invalidArguments)

  
  ###
  Getter / setter for the hashbang
  
  @method hash
  @param  {String} arg Route to set
  @return {String}     Current route
  ###
  hash: (arg) ->
    output = ""
    unless typeof arg is "undefined"
      output = arg.replace(route.bang, "")
      document.location.hash = "!/" + output
    output

  
  ###
  Initializes the routing by loading the initial OR the first route registered
  
  @method init
  @return {String} Route being loaded
  ###
  init: ->
    val = document.location.hash
    (if val.isEmpty() then route.hash((if abaaso.route.initial isnt null then abaaso.route.initial else array.cast(route.routes.all, true).remove("error").first())) else route.load(val))
    val.replace route.bang, ""

  
  ###
  Lists all routes
  
  @set list
  @param {String} verb  HTTP method
  @return {Mixed}       Hash of routes if not specified, else an Array of routes for a method
  ###
  list: (verb) ->
    result = undefined
    switch true
      when not server
        result = array.cast(route.routes.all, true)
      when typeof verb isnt "undefined"
        result = array.cast(route.routes[route.method(verb)], true)
      else
        result = {}
        utility.iterate route.routes, (v, k) ->
          result[k] = []
          utility.iterate v, (fn, r) ->
            result[k].push r


    result

  
  ###
  Loads the hash into the view
  
  @method load
  @param  {String} name  Route to load
  @param  {Object} arg   HTTP response (node)
  @param  {String} verb  HTTP method
  @return {Mixed}        True or undefined
  ###
  load: (name, arg, verb) ->
    verb = route.method(verb)
    active = ""
    path = ""
    result = true
    find = undefined
    name = name.replace(route.bang, "")
    find = (pattern, method, arg) ->
      if utility.compile(route.regex, "^" + pattern + "$", "i") and route.regex.test(arg)
        active = pattern
        path = method
        false

    switch true
      when typeof route.routes[verb][name] isnt "undefined"
        active = name
        path = verb
      when typeof route.routes.all[name] isnt "undefined"
        active = name
        path = "all"
      else
        utility.iterate route.routes[verb], (v, k) ->
          find k, verb, name

        if active.isEmpty()
          utility.iterate route.routes.all, (v, k) ->
            find k, "all", name

    if active.isEmpty()
      active = "error"
      path = "all"
      result = false
    route.routes[path][active] arg or active
    result

  
  ###
  Creates a Server with URI routing
  
  @method server
  @param  {Object}   arg  Server options
  @param  {Function} fn   Error handler
  @param  {Boolean}  ssl  Determines if HTTPS server is created
  @return {Undefined}     undefined
  ###
  server: (args, fn, ssl) ->
    args = args or {}
    ssl = (ssl is true or args.port is 443)
    throw Error(label.error.notSupported)  unless server
    
    # Enabling routing, in case it's not explicitly enabled prior to route.server()
    $.route.enabled = abaaso.route.enabled = true
    
    # Server parameters
    args.host = args.host or "127.0.0.1"
    args.port = parseInt(args.port) or 8000
    unless ssl
      http.createServer((req, res) ->
        route.load require("url").parse(req.url).pathname, res, req.method
      ).on("error", (e) ->
        error e, this, arguments_
        fn e  if typeof fn is "function"
      ).listen args.port, args.host
    else
      https.createServer(args, (req, res) ->
        route.load require("url").parse(req.url).pathname, res, req.method
      ).on("error", (e) ->
        error e, this, arguments_
        fn e  if typeof fn is "function"
      ).listen args.port

  
  ###
  Sets a route for a URI
  
  @method set
  @param  {String}   name  Regex pattern for the route
  @param  {Function} fn    Route listener
  @param  {String}   verb  HTTP method the route is for (default is GET)
  @return {Mixed}          True or undefined
  ###
  set: (name, fn, verb) ->
    verb = (if server then route.method(verb) else "all")
    throw Error(label.error.invalidArguments)  if typeof name isnt "string" or name.isEmpty() or typeof fn isnt "function"
    route.routes[verb][name] = fn
    true