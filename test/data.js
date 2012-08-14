var data   = require("../dist/abaaso.js").data,
    sample = [];

sample.push({
	id        : "8ao7dhfga",
	firstname : "John",
	lastname  : "Doe",
	age       : 30,
	sex       : "male"
});

sample.push({
	id        : "as7d6fts3",
	firstname : "Pepsi",
	lastname  : "Coke",
	age       : 100,
	sex       : "other"
});

// Performing data.batch() "in" and "out" performs all core functions
exports["batch"] = {
	setUp: function (done) {
		this.store = data.register({id: "test"});
		this.store.data.key = "id";
		done();
	},
	direct: function (test) {
		test.expect(4);
		test.equal(this.store.data.batch("set", sample), this.store.data, "Should match");
		test.equal(this.store.data.total, 2, "Should be 2");
		test.equal(this.store.data.batch("del", [0, 1]), this.store.data, "Should match");
		test.equal(this.store.data.total, 0, "Should be 0");
		test.done();
	}
};

exports["find"] = {
	setUp: function (done) {
		this.store = data.register({id: "test"});
		this.store.data.key = "id";
		done();
	},
	direct: function (test) {
		test.expect(3);
		test.equal(this.store.data.batch("set", sample), this.store.data, "Should match");
		test.equal(this.store.data.find("John")[0].key, "8ao7dhfga", "Should be true");
		test.equal(this.store.data.total, 2, "Should be 2");
		test.done();
	}
};

exports["sort"] = {
	setUp: function (done) {
		this.store = data.register({id: "test"});
		this.store.data.key = "id";
		done();
	},
	direct: function (test) {
		test.expect(4);
		test.equal(this.store.data.batch("set", sample), this.store.data, "Should match");
		test.equal(this.store.data.sort("lastname")[0].key, "as7d6fts3", "Should be true");
		test.equal(this.store.data.total, 2, "Should be 2");
		test.equal(this.store.data.views.lastnameCI.length, 2, "Should be 2");
		test.done();
	}
};

exports["storage"] = {
	setUp: function (done) {
		this.store = data.register({id: "test"});
		this.store.data.key = "id";
		done();
	},
	direct: function (test) {
		test.expect(8);
		test.equal(this.store.data.batch("set", sample), this.store.data, "Should match");
		test.equal(this.store.data.storage(this.store.data, "set"), this.store.data, "Should match");
		test.equal(this.store.data.teardown(), this.store.data, "Should match");
		test.equal(this.store.data.total, 0, "Should be 0");
		test.equal(this.store.data.storage(this.store.data, "get"), this.store.data, "Should match");
		test.equal(this.store.data.total, 2, "Should be 2");
		test.equal(this.store.data.storage(this.store.data, "remove"), this.store.data, "Should match");
		test.equal(localStorage.getItem(this.store.id), null, "Should match");
		test.done();
	}
};

exports["teardown"] = {
	setUp: function (done) {
		this.store = data.register({id: "test"});
		this.store.data.key = "id";
		done();
	},
	direct: function (test) {
		test.expect(3);
		test.equal(this.store.data.batch("set", sample), this.store.data, "Should match");
		test.equal(this.store.data.teardown(), this.store.data, "Should match");
		test.equal(this.store.data.total, 0, "Should be 0");
		test.done();
	}
};
