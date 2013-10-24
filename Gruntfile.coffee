Path = require("path")

module.exports = (grunt) ->
  grunt.loadNpmTasks("grunt-contrib-watch")

  grunt.registerMultiTask "barriercli", "Run Barrier test suite", ->
    done = @async()

    files = []

    @files.forEach (pair) ->
      pair.src.forEach (f) ->
        files.push(Path.resolve(f))

    spawnOptions =
      opts:
        env: process.env
        stdio: 'inherit'

      cmd: Path.resolve(Path.join(__dirname, "bin", "barrier"))
      args: grunt.file.expand(files)

    grunt.util.spawn spawnOptions, (err, output) -> done()

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    barriercli:
      all: ["test/helper.coffee", "test/**/*_test.coffee"]

    watch:
      test:
        files: ["test/**/*", "lib/**/*"]
        tasks: ["barriercli"]

  grunt.registerTask "default", ["barriercli", "watch"]
