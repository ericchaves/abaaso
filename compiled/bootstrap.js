var bootstrap, error;

error = utility.error;

bootstrap = function() {
  var $, cleanup, fn, getter, setter;
  cleanup = void 0;
  fn = void 0;
  if (typeof abaaso.bootstrap === "function") {
    delete abaaso.bootstrap;
  }
  abaaso.client.size = client.size();
  client.version();
  client.mobile();
  client.tablet();
  if (client.ie && client.version < 8) {
    return;
  }
  cleanup = function(obj) {
    var nodes;
    nodes = [];
    observer.remove(obj);
    if (obj.childNodes.length > 0) {
      nodes = array.cast(obj.childNodes);
    }
    if (nodes.length > 0) {
      return nodes.each(function(i) {
        return cleanup(i);
      });
    }
  };
  fn = function(e) {
    if (/complete|loaded/.test(document.readyState)) {
      if (typeof abaaso.init === "function") {
        abaaso.init();
      }
      return false;
    }
  };
  if (typeof Array.prototype.filter === "undefined") {
    Array.prototype.filter = function(fn) {
      var i, nth, prop, result, t, val;
      if (this === void 0 || this === null || typeof fn !== "function") {
        throw Error(label.error.invalidArguments);
      }
      i = null;
      t = Object(this);
      nth = t.length >>> 0;
      result = [];
      prop = arguments_[1];
      val = null;
      i = 0;
      while (i < nth) {
        if (i in t) {
          val = t[i];
          if (fn.call(prop, val, i, t)) {
            result.push(val);
          }
        }
        i++;
      }
      return result;
    };
  }
  if (typeof Array.prototype.forEach === "undefined") {
    Array.prototype.forEach = function(callback, thisArg) {
      var O, T, k, kValue, len, _results;
      if (this === null || typeof callback !== "function") {
        throw Error(label.error.invalidArguments);
      }
      T = void 0;
      k = 0;
      O = Object(this);
      len = O.length >>> 0;
      if (thisArg) {
        T = thisArg;
      }
      _results = [];
      while (k < len) {
        kValue = void 0;
        if (k in O) {
          kValue = O[k];
          callback.call(T, kValue, k, O);
        }
        _results.push(k++);
      }
      return _results;
    };
  }
  if (typeof Array.prototype.indexOf === "undefined") {
    Array.prototype.indexOf = function(obj, start) {
      var i, j;
      i = start || 0;
      j = this.length;
      while (i < j) {
        if (this[i] === obj) {
          return i;
        }
        i++;
      }
      return -1;
    };
  }
  if (!server && typeof document.documentElement.classList === "undefined") {
    (function(view) {
      var ClassList, descriptor, getter, proto, target;
      ClassList = void 0;
      getter = void 0;
      proto = void 0;
      target = void 0;
      descriptor = void 0;
      if (("HTMLElement" in view) && ("Element" in view)) {
        return;
      }
      ClassList = function(obj) {
        var classes, self;
        classes = (!obj.className.isEmpty() ? obj.className.explode(" ") : []);
        self = this;
        classes.each(function(i) {
          return self.push(i);
        });
        return this.updateClassName = function() {
          return obj.className = this.join(" ");
        };
      };
      getter = function() {
        return new ClassList(this);
      };
      proto = ClassList["prototype"] = [];
      target = (view.HTMLElement || view.Element)["prototype"];
      proto.add = function(arg) {
        if (!array.contains(this, arg)) {
          this.push(arg);
          return this.updateClassName();
        }
      };
      proto.contains = function(arg) {
        return array.contains(this, arg);
      };
      proto.remove = function(arg) {
        if (array.contains(this, arg)) {
          array.remove(this, arg);
          return this.updateClassName();
        }
      };
      proto.toggle = function(arg) {
        array[(array.contains(this, arg) ? "remove" : "add")](this, arg);
        return this.updateClassName();
      };
      if (Object.defineProperty) {
        descriptor = {
          get: getter,
          enumerable: (!client.ie || client.version > 8 ? true : false),
          configurable: true
        };
        return Object.defineProperty(target, "classList", descriptor);
      } else if (Object.prototype.__defineGetter__) {
        return target.__defineGetter__("classList", getter);
      } else {
        throw Error("Could not create classList shim");
      }
    })(global);
  }
  if (typeof Function.prototype.bind === "undefined") {
    Function.prototype.bind = function(arg) {
      var args, slice;
      fn = this;
      slice = Array.prototype.slice;
      args = slice.call(arguments_, 1);
      return function() {
        return fn.apply(arg, args.concat(slice.call(arguments_)));
      };
    };
  }
  if (server) {
    delete abaaso.cookie;
  }
  $ = abaaso.$.bind($);
  utility.alias($, abaaso);
  delete $.$;
  delete $.bootstrap;
  delete $.callback;
  delete $.data;
  delete $.init;
  delete $.loading;
  abaaso.route.initial = null;
  $.loading = abaaso.loading.create.bind($.loading);
  $.fire = abaaso.fire;
  $.on = abaaso.on;
  $.once = abaaso.once;
  $.un = abaaso.un;
  $.listeners = abaaso.listeners;
  abaaso.state._current = abaaso.state.current = "initial";
  $.state._current = $.state.current = abaaso.state.current;
  if (!server) {
    switch (true) {
      case typeof global.$ === "undefined" || global.$ === null:
        global.$ = $;
        break;
      default:
        global.a$ = $;
        abaaso.aliased = "a$";
    }
  }
  utility.proto(Array, "array");
  if (typeof Element !== "undefined") {
    utility.proto(Element, "element");
  }
  if (typeof HTMLDocument !== "undefined") {
    utility.proto(HTMLDocument, "element");
  }
  utility.proto(Function, "function");
  utility.proto(Number, "number");
  utility.proto(String, "string");
  abaaso.constructor = abaaso;
  $.error.log = abaaso.error.log = [];
  $.on(global, "error", (function(e) {
    return $.fire("error", e);
  }), "error", global, "all");
  if (!server) {
    $.on(global, "hashchange", (function() {
      return $.fire("beforeHash, hash, afterHash", location.hash);
    }), "hash", global, "all");
    $.on(global, "resize", (function() {
      $.client.size = abaaso.client.size = client.size();
      return $.fire("resize", abaaso.client.size);
    }), "resize", global, "all");
    $.on(global, "load", function() {
      return $.fire("render").un("render");
    });
    $.on(global, "DOMNodeInserted", (function(e) {
      var obj;
      obj = e.target;
      if (typeof obj.id !== "undefined" && obj.id.isEmpty()) {
        utility.genId(obj);
        if (obj.parentNode instanceof Element) {
          obj.parentNode.fire("afterCreate", obj);
        }
        return $.fire("afterCreate", obj);
      }
    }), "mutation", global, "all");
    $.on(global, "DOMNodeRemoved", (function(e) {
      return cleanup(e.target);
    }), "mutation", global, "all");
    $.on("hash", (function(arg) {
      if ($.route.enabled || abaaso.route.enabled) {
        return route.load(arg);
      }
    }), "route", abaaso.route, "all");
  }
  getter = void 0;
  setter = void 0;
  getter = function() {
    return this._current;
  };
  setter = function(arg) {
    if (arg === null || typeof arg !== "string" || this.current === arg || arg.isEmpty()) {
      throw Error(label.error.invalidArguments);
    }
    abaaso.state.previous = abaaso.state._current;
    abaaso.state._current = arg;
    return abaaso.fire(arg);
  };
  switch (true) {
    case !client.ie || client.version > 8:
      utility.property(abaaso.state, "current", {
        enumerable: true,
        get: getter,
        set: setter
      });
      utility.property($.state, "current", {
        enumerable: true,
        get: getter,
        set: setter
      });
      break;
    default:
      abaaso.state.change = function(arg) {
        setter.call(abaaso.state, arg);
        return abaaso.state.current = arg;
      };
      $.state.change = function(arg) {
        setter.call(abaaso.state, arg);
        return abaaso.state.current = arg;
      };
  }
  $.ready = true;
  switch (true) {
    case server:
      return abaaso.init();
    case typeof global.define === "function":
      return global.define("abaaso", function() {
        return abaaso.init();
      });
    case /complete|loaded/.test(document.readyState):
      return abaaso.init();
    case typeof document.addEventListener === "function":
      return document.addEventListener("DOMContentLoaded", abaaso.init, false);
    case typeof document.attachEvent === "function":
      return document.attachEvent("onreadystatechange", fn);
    default:
      return utility.timer.init = utility.repeat(fn);
  }
};
