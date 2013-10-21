module.exports = class Expectation
  constructor: (@value, @context) ->

  to: (matcher) ->
