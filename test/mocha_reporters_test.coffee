_                  = require("lodash")
reporters          = require("mocha").reporters
Suite              = require("../lib/suite.coffee")
Runner             = require("../lib/runner.coffee")
{reversibleChange} = require("../lib/util.coffee")

originalLog = console.log
originalWrite = process.stdout.write

disableConsole = ->
  console.log = ->
  process.stdout.write = ->
  ->
    console.log = originalLog
    process.stdout.write = originalWrite

describe "Mocha Reporters", ->
  for key, Reporter of _.omit(reporters, "Markdown", "HTML", "TAP")
    do (key, Reporter) ->
      it "runs the reporter #{key} without any errors", ->
        suite = new Suite()
        runner = new Runner(suite)
        runner.reporter(Reporter)

        suite.withDSL ->
          describe "running a block", ->
            it "passes", -> expect(true).true

        enableConsole = disableConsole()
        runner.run().ensure -> enableConsole()
