Q            = require("q")
RunBlock     = require("./run_block")
RunOnceBlock = require("./run_once_block")
Scope        = require("./scope")
Case         = require("./case")
Exceptation  = require("./expectation")
RunContext   = require("./run_context")
TestReport   = require("./test_report")

tempChange = (object, attributes, callback) ->
  oldValues = {}

  for key, value of attributes
    oldValues[key] = object[key]
    object[key] = value

  restore = ->
    for key, value of oldValues
      object[key] = value

  if callback
    callback()
    restore()
  else
    restore

module.exports = class Suite
  constructor: ->
    @scopes = []
    @testCases = []
    @currentRunContext = null

  lastScope: (ignoreNull = false) ->
    scope = @scopes[@scopes.length - 1] || null

    if !scope && !ignoreNull
      throw new Error("You need to be inside of a describe block to call this command")

    scope

  runContext: -> @currentRunContext || null

  withDSL: (callback) ->
    tempChange global,
      describe:   @describe
      it:         @it
      before:     @before
      beforeEach: @beforeEach
      after:      @after
      afterEach:  @afterEach
      lazy:       @lazy
    , callback

  run: (index = 0, defer = Q.defer()) ->
    tcase = @testCases[index]
    @currentRunContext = new RunContext()
    done = @currentRunContext.done

    if tcase
      g = tempChange(global, expect: @expect, barrierContext: @currentRunContext)

      done.then       => defer.notify(new TestReport(tcase))
      done.fail (err) => defer.notify(new TestReport(tcase, err))
      done.finally    => g(); @run(index + 1, defer)

      try
        tcase.run(@currentRunContext, @testCases[index + 1] || null)
      catch err
        @currentRunContext.defer.reject(err)
    else
      defer.resolve(null)

    defer.promise

  # DSL

  describe: (title, block = ->) =>
    @scopes.push(new Scope(title, @lastScope(true)))
    block()
    @scopes.pop()

  it: (title, block) =>
    scope = @lastScope()
    ccase = new Case(title, block, scope, this)
    @testCases.push(ccase)

  before:     (block) => @lastScope().beforeBlocks.push(new RunOnceBlock(block))
  beforeEach: (block) => @lastScope().beforeBlocks.push(new RunBlock(block))
  after:      (block) => @lastScope().afterBlocks.push(new RunOnceBlock(block))
  afterEach:  (block) => @lastScope().afterEachBlocks.push(new RunBlock(block))

  lazy: (name, block) => @lastScope().addLazy(name, block)

  expect: (value) => new Exceptation(value, @runContext())
