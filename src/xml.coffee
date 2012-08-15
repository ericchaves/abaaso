###
XML methods

@class xml
@namespace abaaso
###
xml =
  
  ###
  Returns XML (Document) Object from a String
  
  @method decode
  @param  {String} arg XML String
  @return {Object}     XML Object or undefined
  ###
  decode: (arg) ->
    try
      throw Error(label.error.invalidArguments)  if typeof arg isnt "string" or arg.isEmpty()
      x = undefined
      if client.ie
        x = new ActiveXObject("Microsoft.XMLDOM")
        x.async = "false"
        x.loadXML arg
      else
        x = new DOMParser().parseFromString(arg, "text/xml")
      return x
    catch e
      error e, arguments_, this
      return `undefined`

  
  ###
  Returns XML String from an Object or Array
  
  @method encode
  @param  {Mixed} arg Object or Array to cast to XML String
  @return {String}    XML String or undefined
  ###
  encode: (arg, wrap) ->
    try
      throw Error(label.error.invalidArguments)  if typeof arg is "undefined"
      wrap = (wrap isnt false)
      x = (if wrap then "<xml>" else "")
      top = (arguments_[2] isnt false)
      node = undefined
      i = undefined
      arg = arg.xml  if arg isnt null and typeof arg.xml isnt "undefined"
      arg = (new XMLSerializer()).serializeToString(arg)  if arg instanceof Document
      node = (name, value) ->
        output = "<n>v</n>"
        output = output.replace(/v/, "<![CDATA[v]]>")  if /\&|\<|\>|\"|\'|\t|\r|\n|\@|\$/g.test(value)
        output.replace(/n/g, name).replace /v/, value

      switch true
        when typeof arg is "boolean", typeof arg is "number", typeof arg is "string"
          x += node("item", arg)
        when typeof arg is "object"
          utility.iterate arg, (v, k) ->
            x += xml.encode(v, (typeof v is "object"), false).replace(/item|xml/g, (if isNaN(k) then k else "item"))

      x += (if wrap then "</xml>" else "")
      x = "<?xml version=\"1.0\" encoding=\"UTF8\"?>" + x  if top
      return x
    catch e
      error e, arguments_, this
      return `undefined`