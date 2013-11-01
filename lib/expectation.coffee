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
  @addMethod:          (name, fn) -> super(name, @promisify(fn, name))
  @addChainableMethod: (name, fn, chainingBehavior) ->
    super(name, @promisify(fn, name), chainingBehavior)

  @overwriteMethod: (name, fn) ->
    _method = Expectation::[name]
    _super = -> this

    _super = _method if _method and _.isFunction(_method)

    Expectation::[name] = ->
      result = Expectation.promisify(fn(_super)).apply(this, arguments)

  @addProperty: (name, getter) -> super(name, @promisify(getter, name))

  @promisify: (fn, name = null) ->
    (args...) ->
      task = @resolveFlags()
        .then => Q.all(args)
        .then (values) => fn.apply(this, values)

      barrierContext.pushTask(task, "expectation #{name}")

      this

  flag: (name, value) ->
    if arguments.length == 1
      @__flags[name]
    else
      @__flags[name] = value

      this

  resolveFlags: ->
    flags = _.keys(@__flags || {})
    promises = _.map flags, (flag) =>
      Q(@__flags[flag]).then (value) =>
        @__flags[flag] = value

    Q.all(promises)

assertions("Assertion": Expectation, utils)
