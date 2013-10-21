Q = require("q")
_ = require("underscore")
matcher = require("./matchers")

module.exports = class Expectation
  constructor: (@value, @context) ->
    @to = this

    matcher.install(this)

  runMatcher: (matcher, args) ->
    argsWithCurrent = [@value].concat(args)

    task = Q.all(argsWithCurrent).then (values) => matcher.apply(this, values)

    @context.pushTask(task)
