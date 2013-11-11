reporters          = require("mocha").reporters
Suite              = require("../lib/suite.coffee")
Runner             = require("../lib/runner.coffee")
{reversibleChange} = require("../lib/util.coffee")

disableConsole = (callback) -> reversibleChange(console, log:(->), callback)

describe "Mocha Reporters", ->
  for key, Reporter of reporters
    it "runs the reporter #{key} without any errors", ->
      suite = new Suite()
      runner = new Runner(suite, Reporter)

      suite.withDSL ->
        describe "running a block", ->
          it "passes", -> expect(true).true
          it "fails", -> throw new Error("fail")

      disableConsole -> runner.run()
