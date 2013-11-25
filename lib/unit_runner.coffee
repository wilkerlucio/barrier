_           = require("lodash")
W           = require("when")
unfold      = require("when/unfold")
sequence    = require("when/sequence")
wfn         = require("when/function")
Exceptation = require("./expectation.coffee")
util        = require("./util.coffee")

module.exports = class UnitRunner
  constructor: (@test) ->
    @lazyCache = {}
    @tasks = []

  run: ->
    dslRevert = util.reversibleChange(global, expect: @expect, barrierContext: this)
    start = new Date

    sequence([].concat(
      @beforeEachBlocks()
      @parallelWait(@test.block)
    )).ensure =>
      @test.duration = new Date - start
      sequence @afterEachBlocks().concat(dslRevert)

  beforeEachBlocks: ->
    _(util.ancestorChain(@test.parent))
      .reverse()
      .invoke("hook", "beforeEach")
      .flatten()
      .map(@injectedBlock)
      .value()

  afterEachBlocks: ->
    _(util.ancestorChain(@test.parent))
      .invoke("hook", "afterEach")
      .flatten()
      .map((block) => => @inject(block).then undefined, -> null)
      .value()

  injectedBlock: (block) => =>
    lazys = util.functionArgNames(block)
    W.all(_.map(lazys, (lazyName) =>
      lazy = util.parentLookup(@test.parent, "lazyBlocks", lazyName)

      if lazy
        if lazy.persist
          lazy._cache ?= @inject(lazy.block)
        else
          @lazyCache[lazyName] ?= @inject(lazy.block)
      else
        W.reject "Lazy block '#{lazyName}' wasn't defined"
    )).then (args) => block.apply(this, args)

  inject: (block) -> @injectedBlock(block)()

  waitFor: (promise) -> @tasks.push(promise)

  parallelWait: (block) -> =>
    @tasks.push(@inject(block))

    unfold(
      => [@tasks.shift(), null]
      => @tasks.length == 0
      ->
    )

  async: ->
    defer = W.defer()
    @waitFor(defer.promise, "async call")

    (err) ->
      if err == undefined
        defer.resolve(null)
      else
        defer.reject(err)

  # DSL Methods

  expect: (args...) => new Exceptation(args...)
