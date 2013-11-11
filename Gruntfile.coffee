Path = require("path")

module.exports = (grunt) ->
  grunt.loadNpmTasks("grunt-contrib-watch")

  grunt.registerMultiTask "barriercli", "Run Barrier test suite", ->
    done = @async()
    options = @options()

    files = []

    @files.forEach (pair) ->
      pair.src.forEach (f) ->
        files.push(Path.resolve(f))

    args = []

    if options.reporter
      args.push "--reporter"
      args.push options.reporter

    spawnOptions =
      opts:
        env: process.env
        stdio: 'inherit'

      cmd: Path.resolve(Path.join(__dirname, "bin", "barrier"))
      args: args.concat grunt.file.expand(files)

    grunt.util.spawn spawnOptions, (err, output) -> done()

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    barriercli:
      all: ["test/helper.coffee", "test/**/*_test.coffee"]
      ci:
        options:
          reporter: "spec"

        src: ["test/helper.coffee", "test/**/*_test.coffee"]

    watch:
      test:
        files: ["Gruntfile.coffee", "test/**/*", "lib/**/*"]
        tasks: ["barriercli:all"]

  grunt.registerTask "default", ["barriercli:all", "watch"]
