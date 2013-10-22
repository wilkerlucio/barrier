Suite       = require("./suite")
DotReporter = require("./reporters/dot")

module.exports = class Runner
  constructor: (options = {}) ->
    @reporter = new DotReporter()
    @suite = new Suite()

  run: (files, callback) ->
    @suite.withDSL => require file for file in files
    p = @suite.run()
    @reporter.attach(p)
    p.done(callback)
