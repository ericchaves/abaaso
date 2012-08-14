###
Number methods

@class number
@namespace abaaso
###
number =
  
  ###
  Returns the difference of arg
  
  @method odd
  @param {Number} arg Number to compare
  @return {Number}    The absolute difference
  ###
  diff: (num1, num2) ->
    throw Error(label.error.expectedNumber)  if isNaN(num1) or isNaN(num2)
    Math.abs num1 - num2

  
  ###
  Tests if an number is even
  
  @method even
  @param {Number} arg Number to test
  @return {Boolean}   True if even, or undefined
  ###
  even: (arg) ->
    arg % 2 is 0

  
  ###
  Formats a Number to a delimited String
  
  @method format
  @param  {Number} arg       Number to format
  @param  {String} delimiter [Optional] String to delimit the Number with
  @param  {String} every     [Optional] Position to insert the delimiter, default is 3
  @return {String}           Number represented as a comma delimited String
  ###
  format: (arg, delimiter, every) ->
    throw Error(label.error.expectedNumber)  if isNaN(arg)
    arg = arg.toString()
    delimiter = delimiter or ","
    every = every or 3
    d = (if arg.indexOf(".") > -1 then "." + arg.replace(/.*\./, "") else "")
    a = arg.replace(/\..*/, "").split("").reverse()
    p = Math.floor(a.length / every)
    i = 1
    n = undefined
    b = undefined
    b = 0
    while b < p
      n = (if i is 1 then every else (every * i) + ((if i is 2 then 1 else (i - 1))))
      a.splice n, 0, delimiter
      i++
      b++
    a = a.reverse().join("")
    a = a.substring(1)  if a.charAt(0) is delimiter
    a + d

  
  ###
  Returns half of a, or true if a is half of b
  
  @param  {Number} a Number to divide
  @param  {Number} b [Optional] Number to test a against
  @return {Mixed}    Boolean if b is passed, Number if b is undefined
  ###
  half: (a, b) ->
    (if typeof b isnt "undefined" then ((a / b) is .5) else (a / 2))

  
  ###
  Tests if a number is odd
  
  @method odd
  @param {Number} arg Number to test
  @return {Boolean}   True if odd, or undefined
  ###
  odd: (arg) ->
    (arg % 2 isnt 0)

  
  ###
  Parses the number
  
  @param  {Mixed} arg Number to parse
  @return {Number}    Integer or float
  ###
  parse: (arg) ->
    (if String(arg).indexOf(".") < 0 then parseInt(arg) else parseFloat(arg))

  
  ###
  Rounds a number up or down
  
  @param  {Number} arg       Float to round
  @param  {String} direction [Optional] "up" or "down", defaults to "down"
  @return {Number}           Rounded interger
  ###
  round: (arg, direction) ->
    return arg  if String(arg).indexOf(".") < 0
    direction = "down"  unless /down|up/.test(direction)
    Math[(if direction is "down" then "floor" else "ceil")] arg