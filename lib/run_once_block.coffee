RunBlock = require("./run_block")

module.exports = class RunOnceBlock extends RunBlock
  constructor: ->
    super

    @runned = false

  run: ->
    unless @runned
      super
      @runned = true
