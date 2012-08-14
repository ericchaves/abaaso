###
Array methods

@class array
@namespace abaaso
###
array =
  
  ###
  Adds 'arg' to 'obj' if it is not found
  
  @method add
  @param  {Array} obj Array to receive 'arg'
  @param  {Mixed} arg Argument to set in 'obj'
  @return {Array}     Array that was queried
  ###
  add: (obj, arg) ->
    obj.push arg  unless array.contains(obj, arg)
    obj

  
  ###
  Returns an Object (NodeList, etc.) as an Array
  
  @method cast
  @param  {Object}  obj Object to cast
  @param  {Boolean} key [Optional] Returns key or value, only applies to Objects without a length property
  @return {Array}       Object as an Array
  ###
  cast: (obj, key) ->
    key = (key is true)
    o = []
    i = undefined
    nth = undefined
    switch true
      when not isNaN(obj.length)
        (if (not client.ie or client.version > 8) then o = Array::slice.call(obj) else utility.iterate(obj, (i, idx) ->
          o.push i  if idx isnt "length"
        ))
      else
        (if key then o = array.keys(obj) else utility.iterate(obj, (i) ->
          o.push i
        ))
    o

  
  ###
  Clones an Array
  
  @method clone
  @param  {Array} obj Array to clone
  @return {Array}     Clone of Array
  ###
  clone: (obj) ->
    utility.clone obj

  
  ###
  Determines if obj contains arg
  
  @method contains
  @param  {Array} obj Array to search
  @param  {Mixed} arg Value to look for
  @return {Boolean}   True if found, false if not
  ###
  contains: (obj, arg) ->
    array.index(obj, arg) > -1

  
  ###
  Finds the difference between array1 and array2
  
  @method diff
  @param  {Array} array1 Source Array
  @param  {Array} array2 Comparison Array
  @return {Array}        Array of the differences
  ###
  diff: (array1, array2) ->
    result = []
    array1.each (i) ->
      result.add i  unless array2.contains(i)

    array2.each (i) ->
      result.add i  unless array1.contains(i)

    result

  
  ###
  Iterates obj and executes fn
  Parameters for fn are 'value', 'key'
  
  @param  {Array}    obj Array to iterate
  @param  {Function} fn  Function to execute on index values
  @return {Array}        Array
  ###
  each: (obj, fn) ->
    nth = obj.length
    i = undefined
    r = undefined
    i = 0
    while i < nth
      r = fn.call(obj, obj[i], i)
      break  if r is false
      i++
    obj

  
  ###
  Returns the first Array node
  
  @method first
  @param  {Array} obj The array
  @return {Mixed}     The first node of the array
  ###
  first: (obj) ->
    obj[0]

  
  ###
  Facade to indexOf for shorter syntax
  
  @method index
  @param  {Array} obj Array to search
  @param  {Mixed} arg Value to find index of
  @return {Number}    The position of arg in instance
  ###
  index: (obj, arg) ->
    obj.indexOf arg

  
  ###
  Returns an Associative Array as an Indexed Array
  
  @method indexed
  @param  {Array} obj Array to index
  @return {Array}     Indexed Array
  ###
  indexed: (obj) ->
    indexed = []
    utility.iterate obj, (v, k) ->
      (if typeof v is "object" then indexed = indexed.concat(array.indexed(v)) else indexed.push(v))

    indexed

  
  ###
  Finds the intersections between array1 and array2
  
  @method intersect
  @param  {Array} array1 Source Array
  @param  {Array} array2 Comparison Array
  @return {Array}        Array of the intersections
  ###
  intersect: (array1, array2) ->
    a = (if array1.length > array2.length then array1 else array2)
    b = (if a is array1 then array2 else array1)
    a.filter (key) ->
      array.contains b, key


  
  ###
  Returns the keys in an Associative Array
  
  @method keys
  @param  {Array} obj Array to extract keys from
  @return {Array}     Array of the keys
  ###
  keys: (obj) ->
    keys = []
    (if typeof Object.keys is "function" then keys = Object.keys(obj) else utility.iterate(obj, (v, k) ->
      keys.push k
    ))
    keys

  
  ###
  Returns the last index of the Array
  
  @method last
  @param  {Array} obj Array
  @return {Mixed}     Last index of Array
  ###
  last: (obj) ->
    obj[obj.length - 1]

  
  ###
  Returns a range of indices from the Array
  
  @param  {Array}  obj   Array to iterate
  @param  {Number} start Starting index
  @param  {Number} end   Ending index
  @return {Array}        Array of indices
  ###
  range: (obj, start, end) ->
    result = []
    i = undefined
    i = start
    while i <= end
      result.push obj[i]  if typeof obj[i] isnt "undefined"
      i++
    result

  
  ###
  Removes indices from an Array without recreating it
  
  @method remove
  @param  {Array}  obj   Array to remove from
  @param  {Number} start Starting index
  @param  {Number} end   [Optional] Ending index
  @return {Array}        Modified Array
  ###
  remove: (obj, start, end) ->
    if typeof start is "string"
      start = obj.index(start)
      return obj  if start is -1
    else
      start = start or 0
    length = obj.length
    remaining = obj.slice((end or start) + 1 or length)
    obj.length = (if start < 0 then (length + start) else start)
    obj.push.apply obj, remaining
    obj

  
  ###
  Sorts the Array by parsing values
  
  @param  {Mixed} a Argument to compare
  @param  {Mixed} b Argument to compare
  @return {Boolean} Boolean indicating sort order
  ###
  sort: (a, b) ->
    nums = false
    result = undefined
    nums = true  if not isNaN(a) and not isNaN(b)
    a = (if nums then number.parse(a) else String(a))
    b = (if nums then number.parse(b) else String(b))
    switch true
      when a < b
        result = -1
      when a > b
        result = 1
      else
        result = 0
    result

  
  ###
  Gets the total keys in an Array
  
  @method total
  @param  {Array} obj Array to find the length of
  @return {Number}    Number of keys in Array
  ###
  total: (obj) ->
    array.indexed(obj).length

  
  ###
  Casts an Array to Object
  
  @param  {Array} ar Array to transform
  @return {Object}   New object
  ###
  toObject: (ar) ->
    obj = {}
    i = ar.length
    obj[i.toString()] = ar[i]  while i--
    obj