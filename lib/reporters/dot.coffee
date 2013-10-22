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

    console.log()
    console.log()
    console.log("  #{success.length} success ".green + "(#{runTime}ms)".grey)
