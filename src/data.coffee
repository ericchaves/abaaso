###
Template data store, use $.store(obj), abaaso.store(obj) or abaaso.data.register(obj)
to register it with an Object

RESTful behavior is supported, by setting the 'key' & 'uri' properties

Do not use this directly!

@class data
@namespace abaaso
###
data =
  
  # Inherited by data stores
  methods:
    
    ###
    Batch sets or deletes data in the store
    
    Events: beforeDataBatch  Fires before the batch is queued
    afterDataBatch   Fires after the batch is queued
    failedDataBatch  Fires when an exception occurs
    
    @method batch
    @param  {String}  type Type of action to perform
    @param  {Mixed}   data Array of keys or indices to delete, or Object containing multiple records to set
    @param  {Boolean} sync [Optional] Syncs store with data, if true everything is erased
    @return {Object}       Data store
    ###
    batch: (type, data, sync) ->
      type = type.toString().toLowerCase()
      sync = (sync is true)
      throw Error(label.error.invalidArguments)  if not /^(set|del)$/.test(type) or typeof data isnt "object"
      obj = @parentNode
      self = this
      r = 0
      nth = 0
      f = false
      guid = utility.genId(true)
      completed = undefined
      failure = undefined
      key = undefined
      set = undefined
      success = undefined
      completed = ->
        self.reindex()  if type is "del"
        self.loaded = true
        obj.fire "afterDataBatch"

      failure = (arg) ->
        obj.fire "failedDataSet, failedDataBatch", arg

      set = (data, key) ->
        guid = utility.genId()
        rec = {}
        if typeof rec.batch isnt "function"
          rec = utility.clone(data)
        else
          $.iterate data, (v, k) ->
            rec[k] = utility.clone(v)  unless self.collections.contains(k)

        if self.key isnt null and typeof rec[self.key] isnt "undefined"
          key = rec[self.key]
          delete rec[self.key]
        obj.once("afterDataSet", ->
          @un "failedDataSet", guid
          completed()  if ++r and r is nth
        , guid).once "failedDataSet", (->
          @un "afterDataSet", guid
          unless f
            f = true
            @fire "failedDataBatch"
        ), guid
        self.set key, rec, sync

      obj.fire "beforeDataBatch", data
      if type is "del"
        obj.on("afterDataDelete", ->
          if r++ and r is nth
            obj.un "afterDataDelete, failedDataDelete", guid
            completed()
        , guid).once "failedDataDelete", (->
          obj.un "afterDataDelete", guid
          unless f
            f = true
            obj.fire "failedDataBatch"
        ), guid
      if data instanceof Array
        nth = data.length
        switch nth
          when 0
            completed()
          else
            data.sort().reverse().each (i, idx) ->
              idx = idx.toString()
              if type is "set"
                switch true
                  when typeof i is "object"
                    set i, idx
                  when i.indexOf("//") is -1
                    i = self.uri + i
                  else
                    i.get ((arg) ->
                      set (if self.source is null then arg else utility.walk(arg, self.source)), idx
                    ), failure, utility.merge(
                      withCredentials: self.credentials
                    , self.headers)
              else
                self.del i, false, sync

      else
        nth = array.cast(data, true).length
        utility.iterate data, (v, k) ->
          if type is "set"
            if self.key isnt null and typeof v[self.key] isnt "undefined"
              key = v[self.key]
              delete v[self.key]
            else
              key = k.toString()
            self.set key, v, sync
          else
            self.del v, false, sync

      this

    
    ###
    Clears the data object, unsets the uri property
    
    Events: beforeDataClear  Fires before the data is cleared
    afterDataClear   Fires after the data is cleared
    
    @method clear
    @param {Boolean} sync [Optional] Boolean to limit clearing of properties
    @return {Object}      Data store
    ###
    clear: (sync) ->
      sync = (sync is true)
      obj = @parentNode
      unless sync
        obj.fire "beforeDataClear"
        @callback = null
        @collections = []
        @crawled = false
        @credentials = null
        @expires = null
        @_expires = null
        @headers = Accept: "application/json"
        @ignore = []
        @key = null
        @keys = {}
        @loaded = false
        @pointer = null
        @records = []
        @recursive = false
        @retrieve = false
        @source = null
        @total = 0
        @views = {}
        @uri = null
        @_uri = null
        obj.fire "afterDataClear"
      else
        @collections = []
        @crawled = false
        @keys = {}
        @loaded = false
        @records = []
        @total = 0
        @views = {}
      this

    
    ###
    Crawls a record's properties and creates data stores when URIs are detected
    
    Events: afterDataRetrieve  Fires after the store has retrieved all data from crawling
    
    @method crawl
    @param  {Mixed}  arg    Record key or index
    @param  {String} ignore [Optional] Comma delimited fields to ignore
    @param  {String} key    [Optional] data.key property to set on new stores, defaults to record.key
    @return {Object}        Record
    ###
    crawl: (arg, ignore, key) ->
      ignored = false
      self = this
      record = undefined
      throw Error(label.error.invalidArguments)  if typeof arg isnt "number" and typeof arg isnt "string"
      @crawled = true
      @loaded = false
      record = @get(arg)
      record = @records[@keys[record.key].index]
      key = key or @key
      if typeof ignore is "string"
        ignored = true
        ignore = ignore.explode()
      utility.iterate record.data, (v, k) ->
        return  if typeof v isnt "string" or (ignored and ignore.contains(k))
        if v.indexOf("//") >= 0
          self.collections.push k  unless self.collections.contains(k)
          record.data[k] = data.register(id: record.key + "-" + k)
          record.data[k].once "afterDataSync", (->
            @fire "afterDataRetrieve"
          ), "dataRetrieve"
          record.data[k].data.headers = utility.merge(record.data[k].data.headers, self.headers)
          ignore.each (i) ->
            record.data[k].data.ignore.add i

          record.data[k].data.key = key
          record.data[k].data.pointer = self.pointer
          record.data[k].data.source = self.source
          if self.recursive and self.retrieve
            record.data[k].data.recursive = true
            record.data[k].data.retrieve = true
          (if typeof record.data[k].data.setUri is "function" then record.data[k].data.setUri(v) else record.data[k].data.uri = v)

      @get arg

    
    ###
    Deletes a record based on key or index
    
    Events: beforeDataDelete  Fires before the record is deleted
    afterDataDelete   Fires after the record is deleted
    syncDataDelete    Fires when the local store is updated
    failedDataDelete  Fires if the store is RESTful and the action is denied
    
    @method del
    @param  {Mixed}   record  Record key or index
    @param  {Boolean} reindex Default is true, will re-index the data object after deletion
    @param  {Boolean} sync    [Optional] True if called by data.sync
    @return {Object}          Data store
    ###
    del: (record, reindex, sync) ->
      throw Error(label.error.invalidArguments)  if typeof record is "undefined" or not /number|string/.test(typeof record)
      reindex = (reindex isnt false)
      sync = (sync is true)
      obj = @parentNode
      r = /true|undefined/
      key = undefined
      args = undefined
      uri = undefined
      p = undefined
      switch typeof record
        when "string"
          key = record
          record = @keys[key]
          throw Error(label.error.invalidArguments)  if typeof key is "undefined"
          record = record.index
        else
          key = @records[record]
          throw Error(label.error.invalidArguments)  if typeof key is "undefined"
          key = key.key
      args =
        key: key
        record: record
        reindex: reindex

      if not sync and @callback is null and @uri isnt null
        uri = @uri + "/" + key
        p = uri.allows("delete")
      obj.fire "beforeDataDelete", args
      switch true
        when sync, @callback isnt null, @uri is null
          obj.fire "syncDataDelete", args
        when r.test(p)
          uri.del (->
            obj.fire "syncDataDelete", args
          ), (->
            obj.fire "failedDataDelete", args
          ), utility.merge(
            withCredentials: @credentials
          , @headers)
        else
          obj.fire "failedDataDelete", args
      this

    
    ###
    Finds needle in the haystack
    
    @method find
    @param  {Mixed}  needle    String, Number or Pattern to test for
    @param  {String} haystack  [Optional] Commma delimited string of the field(s) to search
    @param  {String} modifiers [Optional] Regex modifiers, defaults to "gi" unless value is null
    @return {Array}            Array of results
    ###
    find: (needle, haystack, modifiers) ->
      throw Error(label.error.invalidArguments)  if typeof needle is "undefined"
      needle = (if typeof needle is "string" then needle.explode() else [needle])
      haystack = (if typeof haystack is "string" then haystack.explode() else null)
      result = []
      obj = @parentNode
      keys = []
      regex = new RegExp()
      return result  if @total is 0
      switch true
        when typeof modifiers is "undefined", String(modifiers).isEmpty()
          modifiers = "gi"
        when modifiers is null
          modifiers = ""
      
      # No haystack, testing everything
      if haystack is null
        @records.each (r) ->
          utility.iterate r.data, (v, k) ->
            return false  if keys.contains(r.key)
            return  if typeof v.data is "object"
            needle.each (n) ->
              utility.compile regex, n, modifiers
              if regex.test(v)
                keys.push r.key
                result.add r
                false



      
      # Looking through the haystack
      else
        @records.each (r) ->
          haystack.each (h) ->
            return false  if keys.contains(r.key)
            return  if typeof r.data[h] is "undefined" or typeof r.data[h].data is "object"
            needle.each (n) ->
              utility.compile regex, n, modifiers
              if regex.test(r.data[h])
                keys.push r.key
                result.add r
                false



      result

    
    ###
    Generates a micro-format form from a record
    
    If record is null, an empty form based on the first record is generated.
    The submit action is data.set() which triggers a POST or PUT
    from the data store.
    
    @method form
    @param  {Mixed}   record null, record, key or index
    @param  {Object}  target Target HTML Element
    @param  {Boolean} test   [Optional] Test form before setting values
    @return {Object}         Generated HTML form
    ###
    form: (record, target, test) ->
      test = (test isnt false)
      empty = (record is null)
      self = this
      entity = undefined
      obj = undefined
      handler = undefined
      structure = undefined
      key = undefined
      data = undefined
      switch true
        when empty
          record = @get(0)
        when (record not instanceof Object)
          record = @get(record)
      switch true
        when typeof record is "undefined"
          throw Error(label.error.invalidArguments)
        when @uri isnt null and not @uri.allows("post") # POST & PUT are interchangable for this bit
          throw Error(label.error.serverInvalidMethod)
      key = record.key
      data = record.data
      target = utility.object(target)  if typeof target isnt "undefined"
      if @uri isnt null
        entity = @uri.replace(/.*\//, "").replace(/\?.*/, "")
        entity = entity.replace(/\..*/g, "")  if entity.isDomain()
      else
        entity = "record"
      
      ###
      Button handler
      
      @method handler
      @param  {Object} event Window event
      @return {Undefined}    undefined
      ###
      handler = (event) ->
        form = event.srcElement.parentNode
        nodes = $("#" + form.id + " input")
        entity = nodes[0].name.match(/(.*)\[/)[1]
        result = true
        newData = {}
        guid = undefined
        self.parentNode.fire "beforeDataFormSubmit"
        result = form.validate()  if test
        switch result
          when false
            self.parentNode.fire "failedDataFormSubmit"
          when true
            nodes.each (i) ->
              return  if typeof i.type isnt "undefined" and /button|submit|reset/.test(i.type)
              utility.define i.name.replace("[", ".").replace("]", ""), i.value, newData

            guid = utility.genId(true)
            self.parentNode.once "afterDataSet", ->
              form.destroy()

            self.set key, newData[entity]
        self.parentNode.fire "afterDataFormSubmit", key

      
      ###
      Data structure in micro-format
      
      @method structure
      @param  {Object} record Data store record
      @param  {Object} obj    [description]
      @param  {String} name   [description]
      @return {Undefined}     undefined
      ###
      structure = (record, obj, name) ->
        x = undefined
        id = undefined
        utility.iterate record, (v, k) ->
          switch true
            when v instanceof Array
              x = 0
              v.each (o) ->
                structure o, obj, name + "[" + k + "][" + (x++) + "]"

            when v instanceof Object
              structure v, obj, name + "[" + k + "]"
            else
              id = (name + "[" + k + "]").replace(/\[|\]/g, "")
              obj.create("label",
                for: id
              ).html k.capitalize()
              obj.create "input",
                id: id
                name: name + "[" + k + "]"
                type: "text"
                value: (if empty then "" else v)



      @parentNode.fire "beforeDataForm"
      obj = element.create("form",
        style: "display:none;"
      , target)
      structure data, obj, entity
      obj.create("input",
        type: "button"
        value: label.common.submit
      ).on "click", (e) ->
        handler e

      obj.create "input",
        type: "reset"
        value: label.common.reset

      obj.css "display", "inherit"
      @parentNode.fire "afterDataForm", obj
      obj

    
    ###
    Retrieves a record based on key or index
    
    If the key is an integer, cast to a string before sending as an argument!
    
    @method get
    @param  {Mixed}  record Key, index or Array of pagination start & end
    @param  {Number} end    [Optional] Ceiling for pagination
    @return {Mixed}         Individual record, or Array of records
    ###
    get: (record, end) ->
      records = @records
      obj = @parentNode
      r = undefined
      switch true
        when typeof record is "undefined", String(record).length is 0
          r = records
        when typeof record is "string" and typeof @keys[record] isnt "undefined"
          r = records[@keys[record].index]
        when typeof record is "number" and typeof end is "undefined"
          r = records[parseInt(record)]
        when typeof record is "number" and typeof end is "number"
          r = records.range(parseInt(record), parseInt(end))
        else
          r = `undefined`
      r

    
    ###
    Reindices the data store
    
    @method reindex
    @return {Object} Data store
    ###
    reindex: ->
      nth = @total
      obj = @parentNode
      key = (@key isnt null)
      i = undefined
      @views = {}
      return this  if nth is 0
      i = 0
      while i < nth
        if not key and @records[i].key.isNumber()
          delete @keys[@records[i].key]

          @keys[i.toString()] = {}
          @records[i].key = i.toString()
        @keys[@records[i].key].index = i
        i++
      this

    
    ###
    Storage interface
    
    @param  {Mixed}  obj  Record (Object, key or index) or store
    @param  {Object} op   Operation to perform (get, remove or set)
    @param  {String} type [Optional] Type of Storage to use (session or local, default is session)
    @return {Object}      Record or store
    ###
    storage: (obj, op, type) ->
      record = false
      session = (not server and type isnt "local")
      ns = /number|string/
      result = undefined
      key = undefined
      data = undefined
      throw Error(label.error.invalidArguments)  if not /number|object|string/.test(typeof obj) or not /get|remove|set/.test(op)
      record = (ns.test(obj) or (obj.hasOwnProperty("key") and not obj.hasOwnProperty("parentNode")))
      obj = @get(obj)  if record and (obj not instanceof Object)
      key = (if record then obj.key else obj.parentNode.id)
      switch op
        when "get"
          result = (if session then sessionStorage.getItem(key) else localStorage.getItem(key))
          throw Error(label.error.invalidArguments)  if result is null
          result = json.decode(result)
          (if record then @set(key, result, true) else utility.merge(this, result))
          result = (if record then obj else this)
        when "remove"
          (if session then sessionStorage.removeItem(key) else localStorage.removeItem(key))
          result = this
        when "set"
          data = json.encode((if record then obj.data else
            total: @total
            keys: @keys
            records: @records
          ))
          (if session then sessionStorage.setItem(key, data) else localStorage.setItem(key, data))
          result = this
      result

    
    ###
    Creates or updates an existing record
    
    If a POST is issued, and the data.key property is not set the
    first property of the response object will be used as the key
    
    Events: beforeDataSet  Fires before the record is set
    afterDataSet   Fires after the record is set, the record is the argument for listeners
    syncDataSet    Fires when the local store is updated
    failedDataSet  Fires if the store is RESTful and the action is denied
    
    @method set
    @param  {Mixed}   key  Integer or String to use as a Primary Key
    @param  {Object}  data Key:Value pairs to set as field values
    @param  {Boolean} sync [Optional] True if called by data.sync
    @return {Object}       The data store
    ###
    set: (key, data, sync) ->
      key = `undefined`  if key is null
      sync = (sync is true)
      switch true
        when (typeof key is "undefined" or String(key).isEmpty()) and @uri is null, typeof data is "undefined", data instanceof Array, data instanceof Number, data instanceof String, typeof data isnt "object"
          throw Error(label.error.invalidArguments)
      record = (if typeof key is "undefined" then `undefined` else @get(key))
      obj = @parentNode
      method = (if typeof key is "undefined" then "post" else "put")
      args =
        data: (if typeof record isnt "undefined" then utility.merge(record.data, data) else data)
        key: key
        record: `undefined`

      uri = @uri
      r = /true|undefined/
      p = undefined
      args.record = @records[@keys[record.key].index]  if typeof record isnt "undefined"
      @collections.each (i) ->
        delete args.data[i]  if typeof args.data[i] is "object"

      if not sync and @callback is null and uri isnt null
        uri += "/" + record.key  if typeof record isnt "undefined"
        p = uri.allows(method)
      obj.fire "beforeDataSet",
        key: key
        data: data

      switch true
        when sync, @callback isnt null, @uri is null
          obj.fire "syncDataSet", args
        when r.test(p)
          uri[method] ((arg) ->
            args["result"] = arg
            obj.fire "syncDataSet", args
          ), ((e) ->
            obj.fire "failedDataSet"
          ), data, utility.merge(
            withCredentials: @credentials
          , @headers)
        else
          obj.fire "failedDataSet", args
      this

    
    ###
    Returns a view, or creates a view and returns it
    
    @method sort
    @param  {String} query       SQL (style) order by
    @param  {String} create      [Optional, default behavior is true, value is false] Boolean determines whether to recreate a view if it exists
    @param  {String} sensitivity [Optional] Sort sensitivity, defaults to "ci" (insensitive = "ci", sensitive = "cs", mixed = "ms")
    @return {Array}               View of data
    ###
    sort: (query, create, sensitivity) ->
      throw Error(label.error.invalidArguments)  if typeof query is "undefined" or String(query).isEmpty()
      sensitivity = "ci"  unless /ci|cs|ms/.test(sensitivity)
      create = (create is true)
      view = (query.replace(/\s*asc/g, "").replace(/,/g, " ").toCamelCase()) + sensitivity.toUpperCase()
      queries = query.explode()
      needle = /:::(.*)$/
      asc = /\s*asc$/i
      desc = /\s*desc$/i
      nil = /^null/
      key = @key
      result = []
      bucket = undefined
      sort = undefined
      crawl = undefined
      queries.each (query) ->
        throw Error(label.error.invalidArguments)  if String(query).isEmpty()

      return @views[view]  if not create and @views[view] instanceof Array
      return []  if @total is 0
      crawl = (q, data) ->
        queries = q.clone()
        query = q.first()
        sorted = {}
        result = []
        queries.remove 0
        sorted = bucket(query, data, desc.test(query))
        sorted.order.each (i) ->
          return  if sorted.registry[i].length < 2
          sorted.registry[i] = crawl(queries, sorted.registry[i])  if queries.length > 0

        sorted.order.each (i) ->
          result = result.concat(sorted.registry[i])

        result

      bucket = (query, records, reverse) ->
        query = query.replace(asc, "")
        prop = query.replace(desc, "")
        pk = (key is prop)
        order = []
        registry = {}
        records.each (r) ->
          val = (if pk then r.key else r.data[prop])
          k = (if val is null then "null" else String(val))
          switch sensitivity
            when "ci"
              k = k.toCamelCase()
            when "cs"
              k = k.trim()
            when "ms"
              k = k.trim().slice(0, 1).toLowerCase()
          unless registry[k] instanceof Array
            registry[k] = []
            order.push k
          registry[k].push r

        order.sort array.sort
        order.reverse()  if reverse
        order.each (k) ->
          return  if registry[k].length is 1
          registry[k] = sort(registry[k], query, prop, reverse, pk)

        order: order
        registry: registry

      sort = (data, query, prop, reverse, pk) ->
        tmp = []
        sorted = []
        data.each (i, idx) ->
          v = (if pk then i.key else i.data[prop])
          v = String(v).trim() + ":::" + idx
          tmp.push v.replace(nil, "\"\"")

        if tmp.length > 1
          tmp.sort array.sort
          tmp.reverse()  if reverse
        tmp.each (v) ->
          sorted.push data[needle.exec(v)[1]]

        sorted

      result = crawl(queries, @records)
      @views[view] = result
      result

    
    ###
    Syncs the data store with a URI representation
    
    Events: beforeDataSync  Fires before syncing the data store
    afterDataSync   Fires after syncing the data store
    failedDataSync  Fires when an exception occurs
    
    @method sync
    @param {Boolean} reindex [Optional] True will reindex the data store
    @return {Object}         Data store
    ###
    sync: (reindex) ->
      throw Error(label.error.invalidArguments)  if @uri is null or @uri.isEmpty()
      reindex = (reindex is true)
      self = this
      obj = self.parentNode
      guid = utility.guid(true)
      success = undefined
      failure = undefined
      success = (arg) ->
        try
          throw Error(label.error.expectedObject)  if typeof arg isnt "object"
          data = undefined
          found = false
          guid = utility.genId(true)
          arg = utility.walk(arg, self.source)  if self.source isnt null
          if arg instanceof Array
            data = arg
          else
            utility.iterate arg, (i) ->
              if not found and i instanceof Array
                found = true
                data = i

          data = [arg]  if typeof data is "undefined"
          obj.once "afterDataBatch", ((arg) ->
            self.reindex()  if reindex
            @un("failedDataBatch", guid).fire "afterDataSync", self.get()
          ), guid
          obj.once "failedDataBatch", ((arg) ->
            self.clear true
            @un("afterDataBatch", guid).fire "failedDataSync"
          ), guid
          self.batch "set", data, true
        catch e
          error e, arguments_, this
          obj.fire "failedDataSync", arg

      failure = (e) ->
        obj.fire "failedDataSync", e

      obj.fire "beforeDataSync"
      (if @callback isnt null then @uri.jsonp(success, failure,
        callback: @callback
      ) else @uri.get(success, failure, utility.merge(
        withCredentials: @credentials
      , @headers)))
      this

    
    ###
    Tears down a store & expires all records associated to an API
    
    @return {Undefined} undefined
    ###
    teardown: ->
      uri = @uri
      records = undefined
      id = undefined
      if uri isnt null
        cache.expire uri, true
        observer.remove uri
        id = @parentNode.id + "DataExpire"
        if typeof $.repeating[id] isnt "undefined"
          clearTimeout $.repeating[id]
          delete $.repeating[id]
        records = @get()
        records.each (i) ->
          cache.expire (uri + "/" + i.key), true
          observer.remove uri + "/" + i.key
          utility.iterate i.data, (v, k) ->
            return  if v is null
            if v.hasOwnProperty("data") and typeof v.data.teardown is "function"
              observer.remove v.id
              v.data.teardown()


      @clear true
      this

  
  ###
  Registers a data store on an Object
  
  Events: beforeDataStore  Fires before registering the data store
  afterDataStore   Fires after registering the data store
  
  @method register
  @param  {Object} obj  Object to register with
  @param  {Mixed}  data [Optional] Data to set with this.batch
  @return {Object}      Object registered with
  ###
  register: (obj, data) ->
    if obj instanceof Array
      return obj.each((i) ->
        data.register i, data
      )
    methods =
      expires:
        getter: ->
          @_expires

        setter: (arg) ->
          throw Error(label.error.invalidArguments)  if arg isnt null and @uri is null and isNaN(arg)
          return  if @_expires is arg
          @_expires = arg
          id = @parentNode.id + "DataExpire"
          expires = arg
          self = this
          clearTimeout $.repeating[id]
          delete $.repeating[id]

          return  if arg is null
          utility.defer (->
            utility.repeat (->
              if self.uri is null
                (if typeof self.setExpires is "function" then self.setExpires(null) else self.expires = null)
                return false
              self.uri.fire "beforeExpire, expire, afterExpire"  unless cache.expire(self.uri)
            ), expires, id
          ), expires

      uri:
        getter: ->
          @_uri

        setter: (arg) ->
          throw Error(label.error.invalidArguments)  if arg isnt null and arg.isEmpty()
          switch true
            when @_uri is arg
              return
            when @_uri isnt null
              @_uri.un "expire", "dataSync"
              @teardown true
            else
              @_uri = arg
          if arg isnt null
            arg.on "expire", (->
              @sync true
            ), "dataSync", this
            cache.expire arg, true
            @sync()

    obj = utility.object(obj)
    utility.genId obj
    
    # Hooking observer if not present in prototype chain
    if typeof obj.fire is "undefined"
      obj.fire = (event, arg) ->
        $.fire.call this, event, arg
    if typeof obj.listeners is "undefined"
      obj.listeners = (event) ->
        $.listeners.call this, event
    if typeof obj.on is "undefined"
      obj.on = (event, listener, id, scope, standby) ->
        $.on.call this, event, listener, id, scope, standby
    if typeof obj.once is "undefined"
      obj.once = (event, listener, id, scope, standby) ->
        $.once.call this, event, listener, id, scope, standby
    if typeof obj.un is "undefined"
      obj.un = (event, id) ->
        $.un.call this, event, id
    obj.fire "beforeDataStore"
    obj.data = utility.extend(@methods)
    obj.data.parentNode = obj # Recursion, useful
    obj.data.clear() # Setting properties
    obj.on "syncDataDelete", ((data) ->
      record = @get(data.record)
      @records.remove @records.index(data.record)
      delete @keys[data.key]

      @total--
      @views = {}
      @reindex()  if data.reindex
      utility.iterate record.data, (v, k) ->
        return  if v is null
        v.data.teardown()  if typeof v.data isnt "undefined" and typeof v.data.teardown is "function"

      @parentNode.fire "afterDataDelete", record
      @parentNode
    ), "recordDelete", obj.data
    obj.on "syncDataSet", ((arg) ->
      data = (if typeof arg.record is "undefined" then utility.clone(arg) else arg)
      fire = true
      self = this
      record = undefined
      uri = undefined
      switch true
        when typeof data.record is "undefined"
          index = @total
          @total++
          if typeof data.key is "undefined"
            if typeof data.result is "undefined"
              @fire "failedDataSet"
              throw Error(label.error.expectedObject)
            data.result = utility.walk(data.result, @source)  if @source isnt null
            unless @key is null
              data.key = data.result[@key]
              delete data.result[@key]
            data.key = data.key.toString()  if typeof data.key isnt "string"
            data.data = data.result
          @keys[data.key] = {}
          @keys[data.key].index = index
          @records[index] = {}
          record = @records[index]
          record.key = data.key
          if @pointer is null or typeof data.data[@pointer] is "undefined"
            record.data = data.data
            delete @records[index].data[@key]  if @key isnt null and @records[index].data.hasOwnProperty(@key)
          else
            fire = false
            uri = data.data[@pointer]
            if typeof uri is "undefined" or uri is null
              delete @records[index]

              delete @keys[data.key]

              @fire "failedDataSet"
              throw Error(label.error.expectedObject)
            record.data = {}
            uri.get ((args) ->
              args = utility.walk(args, self.source)  if self.source isnt null
              delete args[self.key]  if typeof args[self.key] isnt "undefined"
              utility.merge record.data, args
              if self.retrieve
                self.crawl record.key, (if self.ignore.length > 0 then self.ignore.join(",") else `undefined`), self.key
                self.loaded = true
              self.parentNode.fire "afterDataSet", record
            ), (->
              self.parentNode.fire "failedDataSet"
            ), self.headers
        else
          data.record.data = data.data
          record = data.record
      @views = {}
      @crawl record.key, (if @ignore.length > 0 then @ignore.join(",") else `undefined`), @key  if @retrieve
      @parentNode.fire "afterDataSet", record  if fire
    ), "recordSet", obj.data
    
    # Getters & setters
    switch true
      when (not client.ie or client.version > 8)
        utility.property obj.data, "uri",
          enumerable: true
          get: methods.uri.getter
          set: methods.uri.setter

        utility.property obj.data, "expires",
          enumerable: true
          get: methods.expires.getter
          set: methods.expires.setter

      else # Only exists when no getters/setters (IE8)
        obj.data.setExpires = (arg) ->
          obj.data.expires = arg
          methods.expires.setter.call obj.data, arg

        obj.data.setUri = (arg) ->
          obj.data.uri = arg
          methods.uri.setter.call obj.data, arg
    obj.data.batch "set", data  if typeof data is "object"
    obj.fire "afterDataStore"
    obj