module.exports = class RunBlock
  constructor: (@block) ->
  run: -> @block()
