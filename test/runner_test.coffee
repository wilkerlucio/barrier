_           = require("underscore")
W           = require("when")
{reporters} = require("mocha")
Suite       = requireLib("suite")
Runner      = requireLib("runner")
S           = JSON.stringify

class SpyReporter
  sinon = require("sinon")

  constructor: (@runner) ->
    @events = []

    oldEmit = @runner.emit

    @runner.emit = =>
      @events.push(Array::slice.call(arguments, 0))
      oldEmit.apply(@runner, arguments)

  check: (events) ->
    while events.length
      current = @events.shift()
      checker = events.shift()

      expect(current, "expected #{checker[0]} to be called into right time, remaining events", @events).eql(checker)

    expect(@events).length(0)

  calledSpy: -> _.tap sinon.spy(), (spy) -> spy()

describe "Runner", ->
  lazy "runner", (suite, reporterClass) ->
    runner = new Runner(suite)
    runner.reporter(reporterClass)
    runner

  lazy "suite", -> new Suite()
  lazy "reporter", (runner) -> runner._reporter
  lazy "reporterClass", -> null

  describe "initialize", ->
    it "raises error if the suite is not given", ->
      expect(-> new Runner()).throw "invalid suite"
      expect(-> new Runner(null)).throw "invalid suite"
      expect(-> new Runner({})).throw "invalid suite"

    it "inits with default runner and creates the suite", (runner) ->
      expect(runner.suite).instanceOf(Suite)

  describe "reporter", ->
    it "works by sending the mocha reporter name", (suite) ->
      runner = new Runner(suite)
      runner.reporter("spec")

      expect(runner.reporter()).instanceOf(require("mocha").reporters.Spec)

    it "works by sending the reporter function", (suite) ->
      runner = new Runner(suite)
      runner.reporter(require("mocha").reporters.Dot)

      expect(runner.reporter()).instanceOf(require("mocha").reporters.Dot)

    it "raises error when using invalid option", (suite) ->
      runner = new Runner(suite)
      expect(-> runner.reporter("invalid")).throw "Cannot find reporter 'invalid'"

  describe "#run", ->
    lazy "reporterClass", -> SpyReporter
    lazy "ctx", -> {}

    it "returns a promise", (runner) ->
      expect(runner.run()).hold.respondTo("then")

    it "running with no tests", ->
      suite = new Suite()
      runner = new Runner(suite)
      runner.reporter(SpyReporter)

      runner.run().then -> runner.reporter().check([
        [ "start" ]
        [ "end" ]
      ])

    testRunTest = (testDesc, result, testFn, args = []) ->
      it testDesc, (ctx) ->
        suite = new Suite()
        ctx.context = suite.context "", ->
          ctx.test = suite.test "", testFn
        runner = new Runner(suite, timeout: 20)
        runner.reporter(SpyReporter)

        runner.run().then -> runner.reporter().check([
          [ "start" ]
          [ "suite",     ctx.context ]
          [ "test",      ctx.test ]
          [ result,      ctx.test ].concat(args)
          [ "test end",  ctx.test ]
          [ "suite end", ctx.context ]
          [ "end" ]
        ])

    testRunTest "runs with a pending test", "pending"
    testRunTest "runs with a passing test", "pass", ->
    testRunTest "runs with a failing test", "fail", (-> throw "This failed"), "This failed"
    testRunTest "runs with a timeout failing test", "fail", (-> @async()), {}
    testRunTest "runs with a test that returns a promise", "pass", -> W(null)
    testRunTest "runs with a failing promise test", "fail", (-> W.reject("error")), "error"

    testRunTestMultiple = (testDesc, result, testFn, args = []) ->
      it testDesc, (ctx) ->
        suite = new Suite()
        ctx.context = suite.context "", ->
          ctx.test = suite.test "", testFn
          ctx.test2 = suite.test "", ->
        runner = new Runner(suite)
        runner.reporter(SpyReporter)

        runner.run().then -> runner.reporter().check([
          [ "start" ]
          [ "suite",     ctx.context ]
          [ "test",      ctx.test ]
          [ result,      ctx.test ].concat(args)
          [ "test end",  ctx.test ]
          [ "test",      ctx.test2 ]
          [ "pass",      ctx.test2 ]
          [ "test end",  ctx.test2 ]
          [ "suite end", ctx.context ]
          [ "end" ]
        ])

    testRunTestMultiple "runs with a pending test", "pending"
    testRunTestMultiple "runs with a passing test", "pass", ->
    testRunTestMultiple "runs with a failing test", "fail", (-> throw "This failed"), "This failed"
    testRunTestMultiple "runs with a test that returns a promise", "pass", -> W(null)
    testRunTestMultiple "runs with a failing promise test", "fail", (-> W.reject("error")), "error"

    it "runs correctly with multiple contexts and tests", (ctx) ->
      suite = new Suite()
      ctx.context = suite.context "", ->
        ctx.test2 = suite.test "", ->
        ctx.context2 = suite.context "", ->
          ctx.test = suite.test "", ->

      runner = new Runner(suite)
      runner.reporter(SpyReporter)

      runner.run().then -> runner.reporter().check([
        [ "start" ]
        [ "suite",     ctx.context ]
          [ "test",      ctx.test2 ]
          [ "pass",      ctx.test2 ]
          [ "test end",  ctx.test2 ]
          [ "suite",     ctx.context2 ]
            [ "test",      ctx.test ]
            [ "pass",      ctx.test ]
            [ "test end",  ctx.test ]
          [ "suite end", ctx.context2 ]
        [ "suite end", ctx.context ]
        [ "end" ]
      ])

    describe "before blocks", ->
      it "runs before blocks once before test", (ctx) ->
        suite = new Suite()
        runCount = 0
        ctx.context = suite.context "", ->
          ctx.before = suite.hook "before", -> runCount++
          ctx.test1 = suite.test "", ->
          ctx.test2 = suite.test "", ->

        runner = new Runner(suite)
        runner.reporter(SpyReporter)

        runner.run().then ->
          runner.reporter().check([
            [ "start" ]
            [ "suite", ctx.context ]
              [ "hook",      ctx.before, "before" ]
              [ "hook end",  ctx.before, "before" ]
              [ "test",      ctx.test1 ]
              [ "pass",      ctx.test1 ]
              [ "test end",  ctx.test1 ]
              [ "test",      ctx.test2 ]
              [ "pass",      ctx.test2 ]
              [ "test end",  ctx.test2 ]
            [ "suite end", ctx.context ]
            [ "end" ]
          ])

          expect(runCount).eq(1)

      it "ends the entire suite if a before hook fails", (ctx) ->
        suite = new Suite()
        ctx.context = suite.context "", ->
          ctx.before = suite.hook "before", -> throw "err"
          ctx.test1 = suite.test "", ->

        runner = new Runner(suite)
        runner.reporter(SpyReporter)

        runner.run().otherwise ->
          runner.reporter().check([
            [ "start" ]
            [ "suite", ctx.context ]
            [ "hook",  ctx.before, "before" ]
            [ "end" ]
          ])

    describe "after blocks", ->
      it "runs after blocks after the context", (ctx) ->
        suite = new Suite()
        ctx.context = suite.context "", ->
          ctx.after = suite.hook "after", ->
          ctx.test1 = suite.test "", ->
          ctx.test2 = suite.test "", ->

        runner = new Runner(suite)
        runner.reporter(SpyReporter)

        runner.run().then ->
          runner.reporter().check([
            [ "start" ]
            [ "suite", ctx.context ]
              [ "test",      ctx.test1 ]
              [ "pass",      ctx.test1 ]
              [ "test end",  ctx.test1 ]
              [ "test",      ctx.test2 ]
              [ "pass",      ctx.test2 ]
              [ "test end",  ctx.test2 ]
              [ "hook",      ctx.after, "after" ]
              [ "hook end",  ctx.after, "after" ]
            [ "suite end", ctx.context ]
            [ "end" ]
          ])

      it "ends the entire suite if a after hook fails", (ctx) ->
        suite = new Suite()
        ctx.context = suite.context "", ->
          ctx.context2 = suite.context "", ->
            ctx.after = suite.hook "after", -> throw "err"
            ctx.test1 = suite.test "", ->

          ctx.test2 = suite.test "", ->

        runner = new Runner(suite)
        runner.reporter(SpyReporter)

        runner.run().otherwise ->
          runner.reporter().check([
            [ "start" ]
            [ "suite", ctx.context ]
              [ "test",     ctx.test2 ]
              [ "pass",     ctx.test2 ]
              [ "test end", ctx.test2 ]
              [ "suite",    ctx.context2 ]
                [ "test",     ctx.test1 ]
                [ "pass",     ctx.test1 ]
                [ "test end", ctx.test1 ]
                [ "hook",     ctx.after, "after" ]
            [ "end" ]
          ])
