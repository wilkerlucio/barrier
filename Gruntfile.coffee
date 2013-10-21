module.exports = (grunt) ->
  grunt.loadNpmTasks("grunt-contrib-watch")

  grunt.registerMultiTask "barriercli", "Run Barrier test suite", ->
    Suite = require("./lib/suite")
    DotReporter = require("./lib/reporters/dot")
    reporter = new DotReporter()

    suite = new Suite()
    suite.globalize =>
      @files.forEach (pair) ->
        pair.src.forEach (f) ->
          require "./#{f}"

    p = suite.run()
    reporter.attach(p)
    p.done(@async())

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    barriercli:
      all: ["test/helper.coffee", "test/**/*_test.coffee"]

    watch:
      test:
        files: ["test/**/*", "lib/**/*"]
        tasks: ["barriercli"]

  grunt.registerTask "default", ["watch"]
