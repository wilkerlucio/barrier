RunBlock = require("./run_block.coffee")

module.exports = class RunOnceBlock extends RunBlock
  constructor: ->
    super

    @runned = false

  run: ->
    unless @runned
      @runned = true
      super
