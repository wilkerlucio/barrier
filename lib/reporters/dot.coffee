_ = require("underscore")
colors = require("colors")

module.exports = class DotReporter
  constructor: ->
    @results = []
    @out = process.stdout

  attach: (promise) ->
    @startTime = (new Date()).getTime()

    console.log()
    @out.write("  ")
    promise.progress (result) =>
      @results.push(result)
      @report(result)

    promise.done @summary

  report: (result) =>
    if result.isFailed()
      @out.write("F".red)
    else
      @out.write(".".green)

  summary: =>
    runTime = (new Date()).getTime() - @startTime
    success = _.filter @results, (r) -> r.isSuccess()
    failed = _.filter @results, (r) -> r.isFailed()

    @log()
    @log()

    if failed.length > 0
      for {test, err} in failed
        @log(test.fullTitle().red)
        @log(err.stack.red)
        @log()

    @log("#{success.length} success ".green + "(#{runTime}ms)".grey)
    @log("#{failed.length} failed ".red) if failed.length > 0

  log: (message = "") -> console.log("  #{message}")
