array =
  cast : (obj, key = false) ->  
    o = []
    unless isNan obj.length
    if !client.ie or client.version > 8
      o = Array::slice.call obj
    else
      utility.iterate obj, (i, idx) ->
      o.push i unless idx is "length"
    else
      if key
        o = array.keys obj
      else
        utility.iterate obj, (i) -> o.push i
    o
