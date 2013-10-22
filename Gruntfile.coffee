Path = require("path")

module.exports = (grunt) ->
  grunt.loadNpmTasks("grunt-contrib-watch")

  grunt.registerMultiTask "barriercli", "Run Barrier test suite", ->
    Runner = require("./lib/runner")

    files = []

    @files.forEach (pair) ->
      pair.src.forEach (f) ->
        files.push(Path.resolve(f))

    runner = new Runner()
    runner.run(files, @async())

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    barriercli:
      all: ["test/helper.coffee", "test/**/*_test.coffee"]

    watch:
      test:
        files: ["test/**/*", "lib/**/*"]
        tasks: ["barriercli"]

  grunt.registerTask "default", ["watch"]
