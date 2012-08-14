###
String methods

@class string
@namespace abaaso
###
string =
  
  ###
  Capitalizes the String
  
  @param  {String} obj String to capitalize
  @return {String}     Capitalized String
  ###
  capitalize: (obj) ->
    obj = string.trim(obj)
    obj.charAt(0).toUpperCase() + obj.slice(1)

  
  ###
  Escapes meta characters within a string
  
  @param  {String} obj String to escape
  @return {String}     Escaped string
  ###
  escape: (obj) ->
    obj.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"

  
  ###
  Splits a string on comma, or a parameter, and trims each value in the resulting Array
  
  @param  {String} obj String to capitalize
  @param  {String} arg String to split on
  @return {Array}      Array of the exploded String
  ###
  explode: (obj, arg) ->
    arg = ","  if typeof arg is "undefined" or arg.toString() is ""
    string.trim(obj).split new RegExp("\\s*" + arg + "\\s*")

  
  ###
  Replaces all spaces in a string with dashes
  
  @param  {String} obj String to hyphenate
  @return {String}     String with dashes instead of spaces
  ###
  hyphenate: (obj) ->
    string.trim(obj).replace /\s+/g, "-"

  
  ###
  Returns singular form of the string
  
  @param  {String} obj String to transform
  @return {String}     Transformed string
  ###
  singular: (obj) ->
    (if /s$/.test(obj) then obj.slice(0, -1) else obj)

  
  ###
  Transforms the case of a String into CamelCase
  
  @param  {String} obj String to capitalize
  @return {String}     Camel case String
  ###
  toCamelCase: (obj) ->
    s = string.trim(obj).toLowerCase().split(" ")
    r = []
    x = 0
    i = undefined
    nth = undefined
    s.each (i) ->
      i = string.trim(i)
      return  if i.isEmpty()
      r.push (if x++ is 0 then i else string.capitalize(i))

    r.join ""

  
  ###
  Trims the whitespace around a String
  
  @param  {String} obj String to capitalize
  @return {String}     Trimmed String
  ###
  trim: (obj) ->
    obj.replace /^\s+|\s+$/g, ""

  
  ###
  Uncapitalizes the String
  
  @param  {String} obj String to capitalize
  @return {String}     Uncapitalized String
  ###
  uncapitalize: (obj) ->
    obj = string.trim(obj)
    obj.charAt(0).toLowerCase() + obj.slice(1)