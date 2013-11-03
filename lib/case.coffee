_    = require("underscore")
Q    = require("q")
util = require("./util.coffee")
fk   = util.flag.key

module.exports = class Case
  constructor: (@title, @block, @parent) ->
    @[fk] = _.clone(@parent[fk])
    @parent.tests.push(this)

  run: ->
    context = barrierContext

    chain = @runList(@parent.allBeforeBlocks()).then => context.injectFunction(@block)
    context.pushTask(chain, "test main chain")

  runAfters: (next) ->
    @runList(@parent.allAfterEachBlocks()).then =>
      @runList(@parent.afterBlocks.slice(0)) unless next and next.parent == @parent

  runList: (blocks) ->
    util.qSequence(blocks, prepare: barrierContext.injectFunction)

  fullTitle: ->
    "#{@parent.fullTitle()} #{@title}"

  # this method is here to make Barrier Case compatible with Mocha reporters
  slow: -> this
