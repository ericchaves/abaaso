###
Mouse tracking

@class mouse
@namespace abaaso
###
mouse =
  
  #Indicates whether mouse tracking is enabled
  enabled: false
  
  # Indicates whether to try logging co-ordinates to the console
  log: false
  
  # Mouse coordinates
  diff:
    x: null
    y: null

  pos:
    x: null
    y: null

  prev:
    x: null
    y: null

  
  ###
  Enables or disables mouse co-ordinate tracking
  
  @method track
  @param  {Mixed} n Boolean to enable/disable tracking, or Mouse Event
  @return {Object}  abaaso.mouse
  ###
  track: (e) ->
    m = abaaso.mouse
    switch true
      when typeof e is "object"
        view = document[(if client.ie and client.version < 9 then "documentElement" else "body")]
        x = (if e.pageX then e.pageX else (view.scrollLeft + e.clientX))
        y = (if e.pageY then e.pageY else (view.scrollTop + e.clientY))
        c = false
        c = true  if m.pos.x isnt x
        $.mouse.prev.x = m.prev.x = Number(m.pos.x)
        $.mouse.pos.x = m.pos.x = x
        $.mouse.diff.x = m.diff.x = m.pos.x - m.prev.x
        c = true  if m.pos.y isnt y
        $.mouse.prev.y = m.prev.y = Number(m.pos.y)
        $.mouse.pos.y = m.pos.y = y
        $.mouse.diff.y = m.diff.y = m.pos.y - m.prev.y
        utility.log m.pos.x + " [" + m.diff.x + "], " + m.pos.y + " [" + m.diff.y + "]"  if c and m.log
      when typeof e is "boolean"
        (if e then observer.add(document, "mousemove", abaaso.mouse.track, "tracking") else observer.remove(document, "mousemove", "tracking"))
        $.mouse.enabled = m.enabled = e
    m