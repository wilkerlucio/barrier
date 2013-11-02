_ = require("underscore")
Q = require("q")

util = require("./util.coffee")

module.exports = class Case
  constructor: (@title, @block, @scope) ->
    @scope.tests.push(this)

  run: ->
    context = barrierContext

    chain = @runList(@scope.allBeforeBlocks()).then => context.injectFunction(@block)
    context.pushTask(chain, "test main chain")

  runAfters: (next) ->
    @runList(@scope.allAfterEachBlocks()).then =>
      @runList(@scope.afterBlocks.slice(0)) unless next and next.scope == @scope

  runList: (blocks) ->
    util.qSequence(blocks, prepare: barrierContext.injectFunction)

  fullTitle: ->
    "#{@scope.fullTitle()} #{@title}"

  # this method is here to make Barrier Case compatible with Mocha reporters
  slow: -> this
