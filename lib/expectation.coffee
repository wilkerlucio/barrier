Q = require("q")
_ = require("underscore")
matcher = require("./matchers")

module.exports = class Expectation
  constructor: (@value, @context, @reverse = false) ->
    @to = this

    matcher.install(this)

  not: -> new Expectation(@value, @context, !@reverse)

  runMatcher: (matcher, args) ->
    argsWithCurrent = [@value].concat(args)

    task = Q.all(argsWithCurrent).then (values) =>
      Q(matcher.match.apply(this, values)).then (passed) =>
        if @raiseError(passed)
          throw new Error(@errorMessage(matcher, values))

    @context.pushTask(task)

  raiseError: (bool) -> if @reverse then bool else !bool
  errorMessage: (matcher, values) ->
    fnName = if @reverse then "reverseFailMessage" else "failMessage"
    matcher[fnName].apply(this, values)
