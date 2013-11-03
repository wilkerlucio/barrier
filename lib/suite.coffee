_                        = require("underscore")
Q                        = require("q")
Scope                    = require("./scope.coffee")
Case                     = require("./case.coffee")
Exceptation              = require("./expectation.coffee")
RunContext               = require("./run_context.coffee")
{EventEmitter}           = require("events")
{reversibleChange, flag} = require("./util.coffee")

module.exports = class Suite extends EventEmitter
  constructor: (options = {})->
    @options = _.extend
      timeout: 2000
    , options

    @rootScope  = new Scope(null, null)
    @scopes     = [@rootScope]
    @testCases  = []
    @runContext = null
    @failed     = false

  currentScope: -> _.last @scopes

  withDSL: (callback) ->
    reversibleChange global,
      describe:   @describe
      it:         @it
      before:     @before
      beforeEach: @beforeEach
      after:      @after
      afterEach:  @afterEach
      lazy:       @lazy
      suite:      this
    , callback

  run: ->
    @emit("start")
    @runCase().then =>
      @emit("end")

  runCase: (index = 0, defer = Q.defer()) ->
    tcase = @testCases[index]

    if tcase
      @runContext = new RunContext(tcase)
      g = reversibleChange(global, expect: @expect, barrierContext: @runContext)

      @runContext.done.timeout(@options.timeout)
        .then(=> @emit("pass", tcase))
        .fail (err) =>
          @failed = true
          @emit("fail", tcase, err)
        .finally =>
          tcase.runAfters(@testCases[index + 1] || null).timeout(@options.timeout).finally =>
            g()
            @emit("test end", tcase)
            @runCase(index + 1, defer)

      try
        @emit("test", tcase)
        tcase.run()
      catch err
        @runContext.defer.reject(err)
    else
      defer.resolve(!@failed)

    defer.promise

  # DSL

  describe: (title = null, flags, block) =>
    if _.isFunction(flags)
      block = flags
      flags = {}

    _.tap new Scope(title, @currentScope()), (scope) =>
      flag(scope, key, value) for key, value of flags

      if block
        @scopes.push(scope)
        block()
        @scopes.pop()

  it: (title, flags, block) =>
    if _.isFunction(flags)
      block = flags
      flags = {}

    _.tap new Case(title, block, @currentScope(), this), (ccase) =>
      flag(ccase, key, value) for key, value of flags
      flag(ccase, "pending", true) unless _.isFunction block
      @testCases.push(ccase)

  test: => @it.apply(this, arguments)

  before:     (block) => @currentScope().beforeBlocks.push(_.once(block))
  beforeEach: (block) => @currentScope().beforeBlocks.push(block)
  after:      (block) => @currentScope().afterBlocks.push(_.once(block))
  afterEach:  (block) => @currentScope().afterEachBlocks.push(block)

  lazy: (args...) => @currentScope().addLazy(args...)

  expect: (args...) => new Exceptation(args...)

  toJSON: -> rootScope: @rootScope.toJSON()
