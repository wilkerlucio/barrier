_            = require("underscore")
Q            = require("q")
RunBlock     = require("./run_block.coffee")
RunOnceBlock = require("./run_once_block.coffee")
Scope        = require("./scope.coffee")
Case         = require("./case.coffee")
Exceptation  = require("./expectation.coffee")
RunContext   = require("./run_context.coffee")
TestReport   = require("./test_report.coffee")

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
  constructor: (options = {})->
    @options = _.extend
      timeout: 2000
    , options

    @scopes = [new Scope(null, null)]
    @testCases = []
    @currentRunContext = null
    @failed = false

  lastScope: -> _.last @scopes

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
    done = @currentRunContext.done.timeout(@options.timeout)

    if tcase
      g = tempChange(global, expect: @expect, barrierContext: @currentRunContext)

      done.then       => defer.notify(new TestReport(tcase))
      done.fail (err) => @failed = true; defer.notify(new TestReport(tcase, err))
      done.finally    => g(); @run(index + 1, defer)

      try
        tcase.run(@currentRunContext, @testCases[index + 1] || null)
      catch err
        @currentRunContext.defer.reject(err)
    else
      defer.resolve(!@failed)

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

  lazy: (args...) => @lastScope().addLazy(args...)

  expect: (args...) => new Exceptation(args...)
