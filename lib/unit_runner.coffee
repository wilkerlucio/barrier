_    = require("underscore")
Q    = require("q")
util = require("./util.coffee")

module.exports = class UnitRunner
  constructor: (@test) ->
    @lazyCache = {}

  run: ->
    util.qSequence([].concat(
      @beforeEachBlocks()
      @injectedBlock(@test.block)
    )).finally => util.qSequence @afterEachBlocks()

  beforeEachBlocks: ->
    _.flatten(_.invoke util.ancestorChain(@test.parent).reverse(), "hook", "beforeEach")

  afterEachBlocks: ->
    _.map _.flatten(_.invoke util.ancestorChain(@test.parent), "hook", "afterEach"), (block) ->
      -> Q.promised(block)().fail -> null

  injectedBlock: (block) => =>
    lazys = util.functionArgNames(block)
    Q.all(_.map(lazys, (lazyName) =>
      lazy = util.parentLookup(@test.parent, "lazyBlocks", lazyName)

      if lazy
        if lazy.persist
          lazy._cache ?= @injectedBlock(lazy.block)()
        else
          @lazyCache[lazyName] ?= @injectedBlock(lazy.block)()
      else
        Q.reject "Lazy block '#{lazyName}' wasn't defined"
    )).then (args) =>
      block.apply(this, args)
