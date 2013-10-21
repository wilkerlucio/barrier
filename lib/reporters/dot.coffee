module.exports = class DotReporter
  constructor: ->
    @results = []
    @out = process.stdout

  attach: (promise) ->
    promise.progress (result) =>
      @results.push(result)
      @report(result)

    promise.done @summary

  report: (result) =>
    if result.err
      @out.write("F")
    else
      @out.write(".")

  summary: =>
    console.log()
    console.log("SUMMARY")
