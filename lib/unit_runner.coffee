_           = require("underscore")
W           = require("when")
Exceptation = require("./expectation.coffee")
util        = require("./util.coffee")

module.exports = class UnitRunner
  constructor: (@test) ->
    @lazyCache = {}
    @tasks = []

  run: ->
    dslRevert = util.reversibleChange(global, expect: @expect, barrierContext: this)
    start = new Date

    util.qSequence([].concat(
      @beforeEachBlocks()
      @parallelWait(@test.block)
    )).ensure =>
      @test.duration = new Date - start
      util.qSequence @afterEachBlocks().concat(dslRevert)

  beforeEachBlocks: ->
    _.map(_.flatten(_.invoke util.ancestorChain(@test.parent).reverse(), "hook", "beforeEach"), @injectedBlock)

  afterEachBlocks: ->
    _.map _.flatten(_.invoke util.ancestorChain(@test.parent), "hook", "afterEach"), (block) =>
      => @injectedBlock(block)().otherwise -> null

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

  waitFor: (promise) ->
    error = null
    try
      throw new Error()
    catch e
      error = e

    promise.otherwise (err) ->
      stack = error.stack
      err.stack += "\n" + stack.substring(stack.indexOf("\n") + 1)
      throw err

    promise.ensure @taskDone
    @tasks.push(promise)

  parallelWait: (block) ->
    =>
      @inject(block).then =>
        @defer = W.defer()
        @taskDone()
        @defer.promise

  allTasksDone: -> _.every @tasks, (task) -> task.inspect().state != "pending"

  taskDone: =>
    if @defer.promise.inspect().state == "pending" and @allTasksDone()
      @defer.resolve(W.all(@tasks))

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
