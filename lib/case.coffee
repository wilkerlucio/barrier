_    = require("underscore")
Q    = require("q")
util = require("./util.coffee")
fk   = util.flag.key

module.exports = class Case
  constructor: (@title, @block, @parent) ->
    throw "Test Case requires a parent" unless @parent

    @[fk] = _.clone(@parent[fk])
    @parent.tests.push(this)

  run: ->
    context = barrierContext

    chain = @runList(@parent.allBeforeBlocks()).then => context.injectFunction(@block)
    context.waitFor(chain, "test main chain")

  runAfters: (next) ->
    @runList(@parent.allAfterEachBlocks()).then =>
      @runList(@parent.afterBlocks.slice(0)) unless next and next.parent == @parent

  runList: (blocks) ->
    blocks = _.map blocks, (block) -> -> barrierContext.injectFunction(block)
    util.qSequence(blocks)

  fullTitle: ->
    "#{@parent.fullTitle()} #{@title}"

  isPending: -> !@block

  # this method is here to make Barrier Case compatible with Mocha reporters
  slow: -> this
