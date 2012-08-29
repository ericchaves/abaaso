/**
 * XMLHttpRequest shim for node.js
 * 
 * @return {Object} Instance of xhr
 */
var xhr = (function () {
	var url              = require("url"),
	    UNSENT           = 0,
	    OPENED           = 1,
	    HEADERS_RECEIVED = 2,
	    LOADING          = 3,
	    DONE             = 4,
	    XMLHttpRequest, headers, state;

	headers = {
		"User-Agent" : "node.js/" + process.version.replace(/^v/, ""),
		"Accept"     : "*/*"
	};

	/**
	 * Changes the readyState of an XMLHttpRequest
	 * 
	 * @param  {String} arg  New readyState
	 * @return {Object}      XMLHttpRequest
	 */
	state = function (arg) {
		if (this.readyState !== arg) {
			this.readyState = arg;
			if (this._params.async || this.readyState < OPENED || this.readyState === DONE) this.dispatchEvent("readystatechange");
			if (this.readyState === DONE && !this._error) {
				this.dispatchEvent("loadstart");
				this.dispatchEvent("load");
				this.dispatchEvent("loadend");
			}
		}
		return this;
	};

	XMLHttpRequest = function () {
		this.onabort            = null;
		this.onerror            = null;
		this.onload             = null;
		this.onloadend          = null;
		this.onloadstart        = null;
		this.onreadystatechange = null;
		this.readyState         = UNSENT;
		this.response           = null;
		this.responseText       = "";
		this.responseType       = "";
		this.responseXML        = null;
		this.status             = UNSENT;
		this.statusText         = "";

		// Psuedo private for prototype chain
		this._id                = utility.genId();
		this._error             = false;
		this._headers           = headers;
		this._listeners         = {};
		this._params            = {};
		this._request           = null;
		this._response          = null;
		this._send              = false;
		return this;
	};

	/**
	 * Aborts a request
	 * 
	 * @return {Object} XMLHttpRequest
	 */
	XMLHttpRequest.prototype.abort = function () {
		if (this._request !== null) {
			if (typeof this._request.abort === "function") this._request.abort();
			this._request = null;
		}

		this._headers     = headers;
		this.responseText = "";
		this.responseXML  = "";
		this._error       = true;

		if (this._send === true || RegExp(HEADERS_RECEIVED + "|" + LOADING).test(this.readyState)) {
			this._send = false;
			state.call(this, DONE)
		}

		this.readyState = UNSENT;
		return this;
	};

	/**
	 * Adds an event listener to an XMLHttpRequest instance
	 * 
	 * @param {String}   type Event type to listen for
	 * @param {Function} fn   Event handler
	 * @return {Object}       XMLHttpRequest
	 */
	XMLHttpRequest.prototype.addEventListener = function (type, fn) {
		if (!this._listeners.hasOwnProperty(type)) this._listeners[type] = [];
		this._listeners[type].add(fn);
		return this;
    };

	/**
	 * Dispatches an event
	 * 
	 * @param  {String} event Name of event
	 * @return {Object}       XMLHttpRequest
	 */
	XMLHttpRequest.prototype.dispatchEvent = function (event) {
		var self = this;

		if (this["on" + event] === "function") this["on" + event]();
		if (this._listeners.hasOwnProperty(type)) this._listeners[event].each(function (i) { i.call(self); });
		return this;
	};

	/**
	 * Gets all response headers
	 * 
	 * @return {Object} Response headers
	 */
	XMLHttpRequest.prototype.getAllResponseHeaders = function () {
		if (this.readyState < HEADERS_RECEIVED) throw Error("INVALID_STATE_ERR: Headers have not been received");
		return typeof this._response.headers !== "undefined" ? this._response.headers : {};
	};

	/**
	 * Gets a specific response header
	 * 
	 * @param  {String} header Header to get
	 * @return {String}        Response header value
	 */
	XMLHttpRequest.prototype.getResponseHeader = function (header) {
		var result;

		if (this.readyState < HEADERS_RECEIVED) throw Error("INVALID_STATE_ERR: Headers have not been received");
		if (typeof this._response.headers !== "undefined") result = this._response.headers[header] || this._response.headers[header.toLowerCase()];
		return result;
	};

	/**
	 * Prepares an XMLHttpRequest instance to make a request
	 * 
	 * @param  {String}  method   HTTP method
	 * @param  {String}  url      URL to receive request
	 * @param  {Boolean} async    [Optional] Asynchronous request
	 * @param  {String}  user     [Optional] Basic auth username
	 * @param  {String}  password [Optional] Basic auth password
	 * @return {Object}           XMLHttpRequest
	 */
	XMLHttpRequest.prototype.open = function (method, url, async, user, password) {
		if (typeof async !== "undefined" && async !== true) throw Error("Synchronous XMLHttpRequest requests are not supported");

		this.abort();
	    this._error  = false;
	    this._params = {
	    	method   : method,
	    	url      : url,
	    	async    : async    || true,
	    	user     : user     || null,
	    	password : password || null
	    };
	    this.readyState = OPENED;
	    return this;
	};

	/**
	 * Overrides the Content-Type of the request
	 * 
	 * @param  {String} mime Mime type of the request (media type)
	 * @return {Object}      XMLHttpRequest
	 */
	XMLHttpRequest.prototype.overrideMimeType = function (mime) {
		this._headers["Content-Type"] = mime;
		return this;
	};

	/**
	 * Removes an event listener from an XMLHttpRequest instance
	 * 
	 * @param {String}   type Event type to listen for
	 * @param {Function} fn   Event handler
	 * @return {Object}       XMLHttpRequest
	 */
	XMLHttpRequest.prototype.removeEventListener = function (type, fn) {
		if (!this._listeners.hasOwnProperty(type)) return;
		this._listeners[type].remove(fn);
		return this;
	};

	/**
	 * Sends an XMLHttpRequest request
	 * 
	 * @param  {Mixed} data [Optional] Payload to send with the request
	 * @return {Object}     XMLHttpRequest
	 * @todo  finish this method
	 */
	XMLHttpRequest.prototype.send = function (data) {
		data     = data || null;
		var self = this,
		    handler, handlerError, options, parsed, request, obj;

		switch (true) {
			case this.readyState < OPENED:
				throw Error("INVALID_STATE_ERR: Object is not open");
			case this._send:
				throw Error("INVALID_STATE_ERR: Object is sending");
		}

		parsed      = url.parse(this._params.url);
		parsed.port = parsed.port || (parsed.protocol === "https" ? 443 : 80);
		if (this._params.user !== null && this._params.password !== null) parsed.auth = this._params.user + ":" + this._params.password;

		if (data !== null) this._headers["Content-Length"] = data.length;

		options = {
			hostname : parsed.hostname,
			path     : parsed.path,
			port     : parsed.port,
			method   : this._params.method,
			headers  : this._headers
		}

		if (typeof parsed.auth !== "undefined") options.auth = parsed.auth;

		handler = function (res) {
			state.call(self, HEADERS_RECEIVED);

			self.status    = res.statusCode;
			self._response = res;

			res.on("data", function (arg) {
				res.setEncoding("utf8");
				if (arg) self.responseText += arg;
				if (self._send) state.call(self, LOADING);
			});

			res.on("end", function () {
				if (self._send) {
					state.call(self, DONE);
					self._send = false;
				}
			});

			res.on("error", function (err) {
				handleError(err);
			});
		};

		handlerError = function (err) {
			self.status       = 503;
			self.statusText   = err;
			self.responseText = err.stack;
			self._error       = true;
			self.dispatchEvent("error");
			state.call(self, DONE);
		};

		self.dispatchEvent("onreadystatechange");

		obj           = parsed.protocol === "http:" ? http : https;
		request       = obj.request(options, handler).on("error", handlerError);
		self._request = request;

		if (data !== null) request.write(data, "utf8");

		return this;
	};

	/**
	 * Sets a request header of an XMLHttpRequest instance
	 * 
	 * @param {String} header HTTP header
	 * @param {String} value  Header value
	 * @return {Object}       XMLHttpRequest
	 */
	XMLHttpRequest.prototype.setRequestHeader = function (header, value) {
		switch (true) {
			case this.readyState !== OPENED:
				throw Error("INVALID_STATE_ERR: Object is not usable");
			case this._send:
				throw Error("INVALID_STATE_ERR: Object is sending");
		}
		this._headers[header] = value;
		return this;
	};

	return XMLHttpRequest;
})();
