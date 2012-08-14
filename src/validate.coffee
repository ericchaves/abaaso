###
Validation methods and patterns

@class validate
@namespace abaaso
###
validate =
  
  # Regular expression patterns to test against
  pattern:
    alphanum: /^[a-zA-Z0-9]+$/
    boolean: /^(0|1|true|false)?$/
    domain: /^[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?/
    email: /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
    ip: /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    integer: /(^-?\d\d*$)/
    notEmpty: /\w{1,}/
    number: /(^-?\d\d*\.\d*$)|(^-?\d\d*$)|(^-?\.\d\d*$)/
    phone: /^([0-9\(\)\/\+ \-\.]+)$/

  
  ###
  Validates args based on the type or pattern specified
  
  @method test
  @param  {Object} args Object to test {(pattern[name] || /pattern/) : (value || #object.id)}
  @return {Object}      Results
  ###
  test: (args) ->
    exception = false
    invalid = []
    tracked = {}
    value = null
    result = []
    c = []
    inputs = []
    selects = []
    i = undefined
    p = undefined
    o = undefined
    x = undefined
    nth = undefined
    if typeof args.nodeName isnt "undefined" and args.nodeName is "FORM"
      args.genId()  if args.id.isEmpty()
      inputs = $("#" + args.id + " input")
      selects = $("#" + args.id + " select")
      c = c.concat(inputs)  if inputs.length > 0
      c = c.concat(selects)  if selects.length > 0
      c.each (i) ->
        z = {}
        p = undefined
        v = undefined
        r = undefined
        p = (if validate.pattern[i.nodeName.toLowerCase()] then validate.pattern[i.nodeName.toLowerCase()] else ((if (not i.id.isEmpty() and validate.pattern[i.id.toLowerCase()]) then validate.pattern[i.id.toLowerCase()] else "notEmpty")))
        v = i.val()
        v = ""  if v is null
        z[p] = v
        r = validate.test(z)
        unless r.pass
          invalid.push
            element: i
            test: p
            value: v

          exception = true

    else
      utility.iterate args, (i, k) ->
        if typeof k is "undefined" or typeof i is "undefined"
          invalid.push
            test: k
            value: i

          exception = true
          return
        value = (if String(i).charAt(0) is "#" then ((if typeof $(i) isnt "undefined" then $(i).val() else "")) else i)
        switch k
          when "date"
            if isNaN(new Date(value).getYear())
              invalid.push
                test: k
                value: value

              exception = true
          when "domain"
            unless validate.pattern.domain.test(value.replace(/.*\/\//, ""))
              invalid.push
                test: k
                value: value

              exception = true
          when "domainip"
            if not validate.pattern.domain.test(value.replace(/.*\/\//, "")) or not validate.pattern.ip.test(value)
              invalid.push
                test: k
                value: value

              exception = true
          else
            p = (if typeof validate.pattern[k] isnt "undefined" then validate.pattern[k] else k)
            unless p.test(value)
              invalid.push
                test: k
                value: value

              exception = true

    pass: not exception
    invalid: invalid