Q = require("q")

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: (context) ->
    context.pushTask(Q @block.call(context))

  fullTitle: ->
    "#{@scope.fullTitle()} #{@title}"
