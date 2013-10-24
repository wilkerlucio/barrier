Suite       = require("./suite.coffee")
DotReporter = require("./reporters/dot.coffee")

module.exports = class Runner
  constructor: (options = {}) ->
    @reporter = new DotReporter()
    @suite = new Suite()

  run: (files) ->
    @suite.withDSL => require file for file in files
    p = @suite.run()
    @reporter.attach(p)
    p
