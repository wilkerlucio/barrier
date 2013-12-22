_              = require("lodash")
wfn            = require("when/function")
timeout        = require("when/timeout")
sequence       = require("when/sequence")
path           = require("path")
{EventEmitter} = require("events")

Suite          = require("./suite.coffee")
UnitRunner     = require("./unit_runner.coffee")
util           = require("./util.coffee")

module.exports = class Runner extends EventEmitter
  constructor: (@suite, options = {}) ->
    throw "invalid suite" unless @suite? and @suite instanceof Suite

    @bailed = false

    @options = _.extend
      timeout: 2000
      bail: false
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
    @runScope(@suite.rootScope).ensure => @emit("end")

  runScope: (scope) ->
    return if @bailed

    @emit("suite", scope) if scope.parent

    @sequence(scope.hook("before"), ((h) => => @runHook("before", h)))
      .then(=> @sequence(scope.tests, ((test) => => @runTest(test))))
      .then(=> @sequence(scope.children, ((s) => => @runScope(s))))
      .then(=> @sequence(scope.hook("after"), ((h) => => @runHook("after", h))))
      .then(=> @emit("suite end", scope) if scope.parent)

  runTest: (test) ->
    return if @bailed

    @emit("test", test)

    if test.isPending()
      @emit("pending", test)
      @emit("test end", test)
    else
      timeout(@options.timeout, new UnitRunner(test).run())
        .then(=> @emit("pass", test))
        .otherwise (err) =>
          @bailed = true if @options.bail
          @emit("fail", test, err)
        .ensure(=> @emit("test end", test))

  runHook: (name, block) ->
    return if @bailed

    @emit("hook", block, name)

    wfn.call(block)
      .then => @emit("hook end", block, name)

  sequence: (list, prepare) -> sequence(_.map(list, prepare))
