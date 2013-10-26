_ = require("underscore")
Q = require("q")
Path = require("path")

requireChai = (path) ->
  chaiBase = Path.dirname(require.resolve("chai"))
  require Path.join(chaiBase, path)

utils = requireChai("lib/chai/utils")
assertions = requireChai("lib/chai/core/assertions")
AssertionError = requireChai("node_modules/assertion-error")

chai = "AssertionError": AssertionError

requireChai("lib/chai/assertion")(chai, utils)

Assertion = chai.Assertion

module.exports = class Expectation extends Assertion
  @overwriteMethod:    (name, fn) -> super(name, @promisify(fn))
  @addMethod:          (name, fn) -> super(name, @promisify(fn))
  @addChainableMethod: (name, fn, chainingBehavior) ->
    super(name, @promisify(fn), chainingBehavior)

  @promisify: (fn) ->
    (args...) ->
      task = @resolveFlags().then =>
        Q.all(args).then (values) => fn.apply(this, values)

      barrierContext.pushTask(task)

      this

  resolveFlags: ->
    flags = _.keys(@__flags || {})
    promises = _.map flags, (flag) =>
      Q(@__flags[flag]).then (value) =>
        @__flags[flag] = value

    Q.all(promises)

assertions("Assertion": Expectation, utils)
