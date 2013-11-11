_    = require("underscore")
Q    = require("q")
util = require("./util.coffee")
fk   = util.flag.key

module.exports = class Case
  constructor: (@title, @block, @parent) ->
    throw "Test Case requires a parent" unless @parent

    @[fk] = _.clone(@parent[fk])
    @parent.tests.push(this)

    @_slow = 75

  fullTitle: ->
    "#{@parent.fullTitle()} #{@title}"

  isPending: -> !@block

  # this method is here to make Barrier Case compatible with Mocha reporters
  slow: (value) ->
    return @_slow if arguments.length == 0
    @_slow = value
