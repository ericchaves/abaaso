/**
 * Cookie methods
 *
 * @class cookie
 * @namespace abaaso
 */
var cookie = {
	/**
	 * Expires a cookie if it exists
	 *
	 * @method expire
	 * @param  {String} name   Name of the cookie to expire
	 * @param  {String} domain [Optional] Domain to set the cookie for
	 * @param  {Boolea} secure [Optional] Make the cookie only accessible via SSL
	 * @return {String}        Name of the expired cookie
	 */
	expire : function (name, domain, secure) {
		if (cookie.get(name) !== undefined) cookie.set(name, "", "-1s", domain, secure);
		return name;
	},

	/**
	 * Gets a cookie
	 *
	 * @method get
	 * @param  {String} name Name of the cookie to get
	 * @return {Mixed}       Cookie or undefined
	 */
	get : function (name) {
		return utility.coerce(cookie.list()[name]);
	},

	/**
	 * Gets the cookies for the domain
	 *
	 * @method list
	 * @return {Object} Collection of cookies
	 */
	list : function () {
		var result = {},
		    item, items;

		if (document.cookie !== undefined && !document.cookie.isEmpty()) {
			items = document.cookie.explode(";");
			array.each(items, function (i) {
				item = i.explode("=");
				result[decodeURIComponent(string.trim(item[0].toString()))] = decodeURIComponent(string.trim(item[1].toString()));
			});
		}
		return result;
	},

	/**
	 * Creates a cookie
	 *
	 * The offset specifies a positive or negative span of time as day, hour, minute or second
	 *
	 * @method set
	 * @param  {String} name   Name of the cookie to create
	 * @param  {String} value  Value to set
	 * @param  {String} offset A positive or negative integer followed by "d", "h", "m" or "s"
	 * @param  {String} domain [Optional] Domain to set the cookie for
	 * @param  {Boolea} secure [Optional] Make the cookie only accessible via SSL
	 * @return {Object}        The new cookie
	 */
	set : function (name, value, offset, domain, secure) {
		value      = (value || "") + ";"
		offset     = offset || "";
		domain     = typeof domain === "string" ? (" domain=" + domain + ";") : "";
		secure     = (secure === true) ? "; secure" : "";
		var expire = "",
		    span   = null,
		    type   = null,
		    types  = ["d", "h", "m", "s"],
		    regex  = new RegExp(),
		    i      = types.length;

		if (!offset.isEmpty()) {
			while (i--) {
				utility.compile(regex, types[i]);
				if (regex.test(offset)) {
					type = types[i];
					span = parseInt(offset);
					break;
				}
			}

			if (isNaN(span)) throw Error(label.error.invalidArguments);

			expire = new Date();
			switch (type) {
				case "d":
					expire.setDate(expire.getDate() + span);
					break;
				case "h":
					expire.setHours(expire.getHours() + span);
					break;
				case "m":
					expire.setMinutes(expire.getMinutes() + span);
					break;
				case "s":
					expire.setSeconds(expire.getSeconds() + span);
					break;
			}
		}
		if (expire instanceof Date) expire = " expires=" + expire.toUTCString() + ";";
		document.cookie = (string.trim(name.toString()) + "=" + value + expire + domain + " path=/" + secure);
		return cookie.get(name);
	}
};
