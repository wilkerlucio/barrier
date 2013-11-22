_              = require("underscore")
Q              = require("q")
path           = require("path")
{EventEmitter} = require("events")

Suite          = require("./suite.coffee")
UnitRunner     = require("./unit_runner.coffee")
util           = require("./util.coffee")

module.exports = class Runner extends EventEmitter
  constructor: (@suite, options = {}) ->
    throw "invalid suite" unless @suite? and @suite instanceof Suite

    @options = _.extend
      timeout: 2000
    , options

  reporter: (reporter) ->
    if reporter?
      if _.isFunction(reporter)
        @_reporter = new reporter(this)
      else
        reporterClass = null
        reporter ||= "dot"

        try
          reporterPath = path.join(path.dirname(require.resolve("mocha")), "lib", "reporters", reporter)
          reporterClass = require(reporterPath)
          @_reporter = new reporterClass(this)
        catch e
          throw "Cannot find reporter '#{reporter}'"
    else
      @_reporter

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
