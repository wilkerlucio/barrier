Path = require("path")

module.exports = (grunt) ->
  grunt.loadNpmTasks("grunt-contrib-watch")
  grunt.loadNpmTasks("grunt-barrier")
  grunt.loadNpmTasks("grunt-shell")

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    barrier:
      options:
        reporter: "dot"

      dev:
        src: ["test/**/*_test.coffee"]
      ci:
        options:
          cmd: "./bin/barrier"
          reporter: "list"

        src: ["test/helper.coffee", "test/**/*_test.coffee"]

    shell:
      buildweb:
        command: "./node_modules/.bin/browserify -t coffeeify lib/browser.coffee > barrier.js"

    watch:
      options:
        spawn: false

      test:
        files: ["Gruntfile.coffee", "test/**/*", "lib/**/*"]
        tasks: ["barrier:dev"]

  grunt.registerTask "default", ["barrier:all", "watch"]
