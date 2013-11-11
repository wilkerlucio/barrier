_           = require("underscore")
Q           = require("q")
Exceptation = require("./expectation.coffee")
util        = require("./util.coffee")

module.exports = class UnitRunner
  constructor: (@test) ->
    @lazyCache = {}
    @tasks = []

  run: ->
    dslRevert = util.reversibleChange(global, expect: @expect, barrierContext: this)

    util.qSequence([].concat(
      @beforeEachBlocks()
      @parallelWait(@test.block)
    )).finally =>
      util.qSequence @afterEachBlocks().concat(dslRevert)

  beforeEachBlocks: ->
    _.map(_.flatten(_.invoke util.ancestorChain(@test.parent).reverse(), "hook", "beforeEach"), @injectedBlock)

  afterEachBlocks: ->
    _.map _.flatten(_.invoke util.ancestorChain(@test.parent), "hook", "afterEach"), (block) =>
      => @injectedBlock(block)().fail -> null

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

  waitFor: (promise) ->
    promise.finally @taskDone
    @tasks.push(promise)

  parallelWait: (block) ->
    =>
      @waitFor @injectedBlock(block)()

      @defer = Q.defer()
      @defer.promise

  allTasksDone: -> _.every @tasks, (task) -> !task.isPending()

  taskDone: =>
    if @defer.promise.isPending() and @allTasksDone()
      @defer.resolve(Q.all(@tasks))

  async: ->
    defer = Q.defer()
    @waitFor(defer.promise, "async call")

    (err) ->
      if err == undefined
        defer.resolve(null)
      else
        defer.reject(err)

  # DSL Methods

  expect: (args...) => new Exceptation(args...)
