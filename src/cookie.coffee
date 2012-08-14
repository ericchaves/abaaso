###
Cookie methods

@class cookie
@namespace abaaso
###
cookie =
  
  ###
  Expires a cookie if it exists
  
  @method expire
  @param  {String} name   Name of the cookie to expire
  @param  {String} domain [Optional] Domain to set the cookie for
  @param  {Boolea} secure [Optional] Make the cookie only accessible via SSL
  @return {String}        Name of the expired cookie
  ###
  expire: (name, domain, secure) ->
    cookie.set name, "", "-1s", domain, secure  if typeof cookie.get(name) isnt "undefined"
    name

  
  ###
  Gets a cookie
  
  @method get
  @param  {String} name Name of the cookie to get
  @return {Mixed}       Cookie or undefined
  ###
  get: (name) ->
    cookie.list()[name]

  
  ###
  Gets the cookies for the domain
  
  @method list
  @return {Object} Collection of cookies
  ###
  list: ->
    result = {}
    item = undefined
    items = undefined
    if typeof document.cookie isnt "undefined" and not document.cookie.isEmpty()
      items = document.cookie.explode(";")
      items.each (i) ->
        item = i.explode("=")
        result[decodeURIComponent(item[0].toString().trim())] = decodeURIComponent(item[1].toString().trim())

    result

  
  ###
  Creates a cookie
  
  The offset specifies a positive or negative span of time as day, hour, minute or second
  
  @method set
  @param  {String} name   Name of the cookie to create
  @param  {String} value  Value to set
  @param  {String} offset A positive or negative integer followed by "d", "h", "m" or "s"
  @param  {String} domain [Optional] Domain to set the cookie for
  @param  {Boolea} secure [Optional] Make the cookie only accessible via SSL
  @return {Object}        The new cookie
  ###
  set: (name, value, offset, domain, secure) ->
    value = ""  if typeof value is "undefined"
    value += ";"
    offset = ""  if typeof offset is "undefined"
    domain = (if (typeof domain is "string") then (" domain=" + domain + ";") else "")
    secure = (if (secure is true) then "; secure" else "")
    expire = ""
    span = null
    type = null
    types = ["d", "h", "m", "s"]
    regex = new RegExp()
    i = types.length
    unless offset.isEmpty()
      while i--
        utility.compile regex, types[i]
        if regex.test(offset)
          type = types[i]
          span = parseInt(offset)
          break
      throw Error(label.error.invalidArguments)  if isNaN(span)
      expire = new Date()
      switch type
        when "d"
          expire.setDate expire.getDate() + span
        when "h"
          expire.setHours expire.getHours() + span
        when "m"
          expire.setMinutes expire.getMinutes() + span
        when "s"
          expire.setSeconds expire.getSeconds() + span
    expire = " expires=" + expire.toUTCString() + ";"  if expire instanceof Date
    document.cookie = (name.toString().trim() + "=" + value + expire + domain + " path=/" + secure)
    cookie.get name
    