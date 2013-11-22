Suite  = require("./suite.coffee")
Runner = require("./runner.coffee")

ConsoleReporter = (runner) ->
  runner.on "start", ->

  runner.on "suite", (suite) ->
    console.group(suite.title)

  runner.on "test", ->

  runner.on "pass", (test) ->
    console.log("%c #{test.title}", "color: #0c0")

  runner.on "fail", (test, err) ->
    console.error(test.title, err.stack)

  runner.on "pending", ->
  runner.on "hook", ->
  runner.on "test end", ->

  runner.on "suite end", ->
    console.groupEnd()

  runner.on "end", ->

suite = new Suite()
dsl = suite.withDSL()

window.onload = ->
  dsl()

  runner = new Runner(suite)
  runner.reporter ConsoleReporter
  runner.run()
