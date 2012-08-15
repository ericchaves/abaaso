
(function(global) {
  var XMLHttpRequest, abaaso, document, http, https, localStorage, location, navigator, server;
  document = global.document;
  location = global.location;
  navigator = global.navigator;
  server = typeof document === "undefined";
  abaaso = void 0;
  http = void 0;
  https = void 0;
  if (server) {
    http = require("http");
    https = require("https");
    if (typeof Storage === "undefined") {
      localStorage = require("localStorage");
    }
    if (typeof XMLHttpRequest === "undefined") {
      XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
    }
  }
  abaaso = global.abaaso || (function() {
    "use strict";

    var $, bootstrap, error, external;
    $ = void 0;
    bootstrap = void 0;
    error = void 0;
    external = void 0;
    !BODY;
    !BOOTSTRAP;
    return {
      array: array,
      callback: {},
      client: {
        android: client.android,
        blackberry: client.blackberry,
        chrome: client.chrome,
        firefox: client.firefox,
        ie: client.ie,
        ios: client.ios,
        linux: client.linux,
        mobile: client.mobile,
        opera: client.opera,
        osx: client.osx,
        playbook: client.playbook,
        safari: client.safari,
        tablet: client.tablet,
        size: {
          height: 0,
          width: 0
        },
        version: 0,
        webos: client.webos,
        windows: client.windows,
        del: function(uri, success, failure, headers) {
          return client.request(uri, "DELETE", success, failure, null, headers);
        },
        get: function(uri, success, failure, headers) {
          return client.request(uri, "GET", success, failure, null, headers);
        },
        headers: function(uri, success, failure) {
          return client.request(uri, "HEAD", success, failure);
        },
        post: function(uri, success, failure, args, headers) {
          return client.request(uri, "POST", success, failure, args, headers);
        },
        put: function(uri, success, failure, args, headers) {
          return client.request(uri, "PUT", success, failure, args, headers);
        },
        jsonp: function(uri, success, failure, callback) {
          return client.jsonp(uri, success, failure, callback);
        },
        options: function(uri, success, failure) {
          return client.request(uri, "OPTIONS", success, failure);
        },
        permissions: client.permissions
      },
      cookie: cookie,
      data: data,
      element: element,
      json: json,
      label: label,
      loading: {
        create: utility.loading,
        url: null
      },
      message: message,
      mouse: mouse,
      number: number,
      observer: {
        log: observer.log,
        add: observer.add,
        fire: observer.fire,
        list: observer.list,
        once: observer.once,
        remove: observer.remove
      },
      state: {
        _current: null,
        header: null,
        previous: null
      },
      string: string,
      validate: validate,
      xml: xml,
      $: utility.$,
      alias: utility.alias,
      aliased: "$",
      allows: client.allows,
      append: function(type, args, obj) {
        if (obj instanceof Element) {
          obj.genId();
        }
        return element.create(type, args, obj, "last");
      },
      bootstrap: bootstrap,
      clear: element.clear,
      clone: utility.clone,
      coerce: utility.coerce,
      compile: utility.compile,
      create: element.create,
      css: element.css,
      decode: json.decode,
      defer: utility.defer,
      define: utility.define,
      del: function(uri, success, failure, headers) {
        return client.request(uri, "DELETE", success, failure, null, headers);
      },
      destroy: element.destroy,
      encode: json.encode,
      error: utility.error,
      expire: cache.clean,
      expires: 120000,
      extend: utility.extend,
      fire: function(obj, event, arg) {
        var a, all, e, o;
        all = typeof arg !== "undefined";
        o = void 0;
        e = void 0;
        a = void 0;
        o = (all ? obj : this);
        e = (all ? event : obj);
        a = (all ? arg : event);
        if (typeof o === "undefined" || o === $) {
          o = abaaso;
        }
        return observer.fire(o, e, a);
      },
      genId: utility.genId,
      get: function(uri, success, failure, headers) {
        return client.request(uri, "GET", success, failure, null, headers);
      },
      guid: utility.guid,
      headers: function(uri, success, failure) {
        return client.request(uri, "HEAD", success, failure);
      },
      hidden: element.hidden,
      id: "abaaso",
      init: function() {
        delete abaaso.init;
        return $.fire("init").un("init").fire("ready").un("ready");
      },
      iterate: utility.iterate,
      jsonp: function(uri, success, failure, callback) {
        return client.jsonp(uri, success, failure, callback);
      },
      listeners: function(event) {
        var obj;
        obj = this;
        if (typeof obj === "undefined" || obj === $) {
          obj = abaaso;
        }
        return observer.list(obj, event);
      },
      log: utility.log,
      merge: utility.merge,
      module: utility.module,
      object: utility.object,
      on: function(obj, event, listener, id, scope, state) {
        var all, e, i, l, o, s, st;
        all = typeof listener === "function";
        o = void 0;
        e = void 0;
        l = void 0;
        i = void 0;
        s = void 0;
        st = void 0;
        o = (all ? obj : this);
        e = (all ? event : obj);
        l = (all ? listener : event);
        i = (all ? id : listener);
        s = (all ? scope : id);
        st = (all ? state : scope);
        if (typeof o === "undefined" || o === $) {
          o = abaaso;
        }
        if (typeof s === "undefined") {
          s = o;
        }
        return observer.add(o, e, l, i, s, st);
      },
      once: function(obj, event, listener, id, scope, state) {
        var all, e, i, l, o, s, st;
        all = typeof listener === "function";
        o = void 0;
        e = void 0;
        l = void 0;
        i = void 0;
        s = void 0;
        st = void 0;
        o = (all ? obj : this);
        e = (all ? event : obj);
        l = (all ? listener : event);
        i = (all ? id : listener);
        s = (all ? scope : id);
        st = (all ? state : scope);
        if (typeof o === "undefined" || o === $) {
          o = abaaso;
        }
        if (typeof s === "undefined") {
          s = o;
        }
        return observer.once(o, e, l, i, s, st);
      },
      options: function(uri, success, failure) {
        return client.request(uri, "OPTIONS", success, failure);
      },
      permissions: client.permissions,
      position: element.position,
      post: function(uri, success, failure, args, headers) {
        return client.request(uri, "POST", success, failure, args, headers);
      },
      prepend: function(type, args, obj) {
        if (obj instanceof Element) {
          obj.genId();
        }
        return element.create(type, args, obj, "first");
      },
      property: utility.property,
      put: function(uri, success, failure, args, headers) {
        return client.request(uri, "PUT", success, failure, args, headers);
      },
      queryString: utility.queryString,
      ready: false,
      reflect: utility.reflect,
      repeat: utility.repeat,
      route: {
        enabled: false,
        del: route.del,
        hash: route.hash,
        init: route.init,
        list: route.list,
        load: route.load,
        server: route.server,
        set: route.set
      },
      stylesheet: function(arg, media) {
        return element.create("link", {
          rel: "stylesheet",
          type: "text/css",
          href: arg,
          media: media || "print, screen"
        }, $("head")[0]);
      },
      script: function(arg, target, pos) {
        return element.create("script", {
          type: "application/javascript",
          src: arg
        }, target || $("head")[0], pos);
      },
      stop: utility.stop,
      store: function(arg, args) {
        return data.register.call(data, arg, args);
      },
      tpl: utility.tpl,
      un: function(obj, event, id, state) {
        var all, e, i, o, s;
        all = typeof id !== "undefined";
        o = void 0;
        e = void 0;
        i = void 0;
        s = void 0;
        o = (all ? obj : this);
        e = (all ? event : obj);
        i = (all ? id : event);
        s = (all ? state : id);
        if (typeof o === "undefined" || o === $) {
          o = abaaso;
        }
        return observer.remove(o, e, i, s);
      },
      update: element.update,
      version: "{{VERSION}}",
      walk: utility.walk
    };
  })();
  if (typeof abaaso.bootstrap === "function") {
    abaaso.bootstrap();
  }
  switch (true) {
    case typeof exports !== "undefined":
      return module.exports = abaaso;
    case typeof define === "function":
      return define(function() {
        return abaaso;
      });
    default:
      return global.abaaso = abaaso;
  }
})(this);
