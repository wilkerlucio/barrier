_              = require("underscore")
Q              = require("q")
Suite          = require("./suite.coffee")
UnitRunner     = require("./unit_runner.coffee")
Reporter       = require("mocha").reporters.Dot
{EventEmitter} = require("events")
util           = require("./util.coffee")

module.exports = class Runner extends EventEmitter
  constructor: (@suite, @reporter = Reporter, options = {}) ->
    throw "invalid suite" unless @suite? and @suite instanceof Suite

    @options = _.extend
      timeout: 2000
    , options

    @reporter = new @reporter(this)

  run: ->
    @emit("start")
    @runScope(@suite.rootScope).finally =>
      @emit("end")

  runScope: (scope) ->
    @emit("suite", scope) if scope.parent

    @sequence(scope.hook("before"), ((h) => => @runHook("before", h)))
      .then(=> @sequence(scope.tests, ((test) => => @runTest(test))))
      .then(=> @sequence(scope.children, ((s) => => @runScope(s))))
      .then(=> @sequence(scope.hook("after"), ((h) => => @runHook("after", h))))
      .then(=> @emit("suite end", scope) if scope.parent)

  runTest: (test) ->
    @emit("test", test)

    if test.isPending()
      @emit("pending", test)
      @emit("test end", test)
    else
      new UnitRunner(test).run().timeout(@options.timeout)
        .then(=> @emit("pass", test))
        .fail((err) => @emit("fail", test, err))
        .finally(=> @emit("test end", test))

  runHook: (name, block) ->
    @emit("hook", block, name)

    Q.promised(block)()
      .then => @emit("hook end", block, name)

  sequence: (list, prepare) -> util.qSequence(_.map(list, prepare))
