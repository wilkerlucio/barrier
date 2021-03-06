Suite  = require("./suite.coffee")
Runner = require("./runner.coffee")

ConsoleReporter = (runner) ->
  runner.on "start", ->
    console.time("Test Suite")

  runner.on "suite", (suite) ->
    console.group(suite.title)

  runner.on "test", ->

  runner.on "pass", (test) ->
    console.log("%c#{test.title}", "color: #0c0")

  runner.on "fail", (test, err) ->
    console.error(test.title, err.stack)

  runner.on "pending", (test) ->
    console.log("%c#{test.title}", "color: #ccca1b")

  runner.on "hook", ->
  runner.on "test end", ->

  runner.on "suite end", ->
    console.groupEnd()

  runner.on "end", ->
    console.timeEnd("Test Suite")

suite = new Suite()
dsl = suite.withDSL()

window.BarrierRun = ->
  dsl()

  runner = new Runner(suite)
  runner.reporter ConsoleReporter
  runner.run()

window.onload = BarrierRun unless BARRIER_NO_AUTORUN?
