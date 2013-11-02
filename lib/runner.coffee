Q        = require("q")
Suite    = require("./suite.coffee")
Reporter = require("mocha").reporters.Dot

module.exports = class Runner
  constructor: (@reporter = Reporter, options = {}) ->
    @suite = new Suite()
    @reporter = new @reporter(@suite)

  run: (files) ->
    @suite.withDSL => require file for file in files
    @suite.run()
