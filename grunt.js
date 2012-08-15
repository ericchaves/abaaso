module.exports = function (grunt) {
	grunt.initConfig({
		pkg : "<json:package.json>",
		meta : {
        	banner : "/**\n" + 
        	         " * <%= pkg.name %>\n" +
        	         " *\n" +
        	         " * @author <%= pkg.author.name %> <<%= pkg.author.email %>>\n" +
        	         " * @copyright <%= pkg.author.name %> <%= grunt.template.today('yyyy') %>\n" +
        	         " * @license <%= pkg.licenses[0].type %> <<%= pkg.licenses[0].url %>>\n" +
        	         " * @link <%= pkg.homepage %>\n" +
        	         " * @module <%= pkg.name %>\n" +
        	         " * @version <%= pkg.version %>\n" +
        	         " */"
		},
		coffee: {
			compile: {
				options: {
					bare: true
				},
				files: {
					"compiled/core.js": "src/core.coffee",
					"compiled/bootstrap.js": "src/bootstrap.coffee",
					"compiled/body.js": [
						"src/array.coffee",
						"src/cache.coffee",
						"src/client.coffee",
						"src/cookie.coffee",
						"src/data.coffee",
						"src/element.coffee",
						"src/json.coffee",
						"src/label.coffee",
						"src/message.coffee",
						"src/mouse.coffee",
						"src/number.coffee",
						"src/observer.coffee",
						"src/route.coffee",
						"src/string.coffee",
						"src/utility.coffee",
						"src/validate.coffee",
						"src/xml.coffee",
						"src/bootstrap.coffee",
					]
				}
			}
		},
		concat: {
			dist: {
				src : [
					"<banner>",
					"compiled/abaaso.js",
				],
				dest : "dist/abaaso.js"
			}
		},
		lint : {
			files : ["grunt.js"]
		},
		min : {
			"dist/abaaso.min.js" : ["<banner>", "dist/abaaso.js"]
		},
		test : {
			files : ["test/**/*.js"]
		},
		watch : {
			files : "<config:lint.files>",
			tasks : "default"
		},
		jshint : {
			options : {
				curly   : true,
				eqeqeq  : true,
				immed   : true,
				latedef : true,
				newcap  : true,
				noarg   : true,
				sub     : true,
				undef   : true,
				boss    : true,
				eqnull  : true,
				node    : true
			},
			globals: {
				exports : true
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib');

	grunt.registerTask("default", "coffee merge concat version min test");

	grunt.registerTask("merge", function () {
		var dest = "compiled/abaaso.js",
		    core = grunt.file.read("compiled/core.js"),
		    body = grunt.file.read("compiled/body.js"),
		    boot = grunt.file.read("compiled/bootstrap.js");

		console.log("Merging compiled files into compiled/abaaso.js");
		grunt.file.write(dest, core.replace("!BODY;", body).replace("!BOOTSTRAP;", boot));
	});

	grunt.registerTask("version", function () {
		var ver = grunt.config("pkg").version,
		    fn  = "dist/abaaso.js",
		    fp  = grunt.file.read(fn);

		console.log("Setting version to: " + ver);
		grunt.file.write(fn, fp.replace(/{{VERSION}}/g, ver));
	});
};