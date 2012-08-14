###
Cache for RESTful behavior

@class cache
@namespace abaaso
@private
###
cache =
  
  # Collection URIs
  items: {}
  
  ###
  Garbage collector for the cached items
  
  @method clean
  @return {Undefined} undefined
  ###
  clean: ->
    utility.iterate cache.items, (v, k) ->
      cache.expire k  if cache.expired(k)


  
  ###
  Expires a URI from the local cache
  
  Events: expire    Fires when the URI expires
  
  @method expire
  @param  {String}  uri    URI of the local representation
  @param  {Boolean} silent [Optional] If 'true', the event will not fire
  @return {Undefined}      undefined
  ###
  expire: (uri, silent) ->
    silent = (silent is true)
    if typeof cache.items[uri] isnt "undefined"
      delete cache.items[uri]

      uri.fire "beforeExpire, expire, afterExpire"  unless silent
      true
    else
      false

  
  ###
  Determines if a URI has expired
  
  @method expired
  @param  {Object} uri Cached URI object
  @return {Boolean}    True if the URI has expired
  ###
  expired: (uri) ->
    item = cache.items[uri]
    typeof item isnt "undefined" and typeof item.expires isnt "undefined" and item.expires < new Date()

  
  ###
  Returns the cached object {headers, response} of the URI or false
  
  @method get
  @param  {String}  uri    URI/Identifier for the resource to retrieve from cache
  @param  {Boolean} expire [Optional] If 'false' the URI will not expire
  @param  {Boolean} silent [Optional] If 'true', the event will not fire
  @return {Mixed}          URI Object {headers, response} or False
  ###
  get: (uri, expire) ->
    expire = (expire isnt false)
    return false  if typeof cache.items[uri] is "undefined"
    if expire and cache.expired(uri)
      cache.expire uri
      return false
    utility.clone cache.items[uri]

  
  ###
  Sets, or updates an item in cache.items
  
  @method set
  @param  {String} uri      URI to set or update
  @param  {String} property Property of the cached URI to set
  @param  {Mixed} value     Value to set
  @return {Mixed}           URI Object {headers, response} or undefined
  ###
  set: (uri, property, value) ->
    if typeof cache.items[uri] is "undefined"
      cache.items[uri] = {}
      cache.items[uri].permission = 0
    (if property is "permission" then cache.items[uri].permission |= value else ((if property is "!permission" then cache.items[uri].permission &= ~value else cache.items[uri][property] = value)))
    cache.items[uri]