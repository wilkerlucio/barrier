_            = require("underscore")
Q            = require("q")
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
    @runContext = null
    @failed = false

    @describe.skip = (title, block) => @describe(title, block, skip: true)

  lastScope: -> _.last @scopes

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

    if tcase
      return @run(index + 1, defer) if tcase.flag("skip")

      @runContext = new RunContext(tcase)
      done = @runContext.done.timeout(@options.timeout)

      g = tempChange(global, expect: @expect, barrierContext: @runContext)

      done.then       => defer.notify(new TestReport(tcase))
      done.fail (err) => @failed = true; defer.notify(new TestReport(tcase, err))
      done.finally    =>
        tcase.runAfters(@testCases[index + 1] || null).timeout(@options.timeout).finally =>
          g(); @run(index + 1, defer)

      try
        tcase.run()
      catch err
        @runContext.defer.reject(err)
    else
      defer.resolve(!@failed)

    defer.promise

  # DSL

  describe: (title, block, flags = {}) =>
    unless _.isFunction(block)
      flags.skip = true
      block = ->

    scope = new Scope(title, @lastScope(true))
    scope.__flags = flags

    @scopes.push(scope)
    block()
    @scopes.pop()

  it: (title, block, flags = {}) =>
    flags.skip = true unless block

    scope = @lastScope()
    ccase = new Case(title, block, scope, this)
    ccase.__flags = flags
    @testCases.push(ccase)

  before:     (block) => @lastScope().beforeBlocks.push(_.once(block))
  beforeEach: (block) => @lastScope().beforeBlocks.push(block)
  after:      (block) => @lastScope().afterBlocks.push(_.once(block))
  afterEach:  (block) => @lastScope().afterEachBlocks.push(block)

  lazy: (args...) => @lastScope().addLazy(args...)

  expect: (args...) => new Exceptation(args...)
