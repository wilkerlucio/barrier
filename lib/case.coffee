Q = require("q")

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: (context) ->
    @block.call(context)
    Q(null)

  fullTitle: ->
    "#{@scope.fullTitle()} #{@title}"
