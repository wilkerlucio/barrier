_                        = require("lodash")
Scope                    = require("./scope.coffee")
Case                     = require("./case.coffee")
util                     = require("./util.coffee")
{reversibleChange, flag} = util

module.exports = class Suite
  constructor: ->
    @rootScope = new Scope(null, null)
    @children  = [@rootScope]

  currentScope: -> _.last @children

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

  # DSL

  describe: (title = null, flags, block) =>
    if _.isFunction(flags)
      block = flags
      flags = {}

    _.tap new Scope(title, @currentScope()), (scope) =>
      flag(scope, key, value) for key, value of flags

      if block
        @children.push(scope)
        block()
        @children.pop()

  it: (title, flags, block) =>
    if _.isFunction(flags)
      block = flags
      flags = {}

    _.tap new Case(title, block, @currentScope(), this), (ccase) =>
      flag(ccase, key, value) for key, value of flags
      flag(ccase, "pending", true) unless _.isFunction block

  context: => @describe.apply(this, arguments)
  test: => @it.apply(this, arguments)

  before:     (block) => @currentScope().hook "before", block
  beforeEach: (block) => @currentScope().hook "beforeEach", block
  after:      (block) => @currentScope().hook "after", block
  afterEach:  (block) => @currentScope().hook "afterEach", block

  hook:  (context, block) => @currentScope().hook(context, block)

  lazy: (args...) => @currentScope().addLazy(args...)

  toJSON: -> rootScope: @rootScope.toJSON()
