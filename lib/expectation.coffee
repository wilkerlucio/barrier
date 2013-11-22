require("better-stack-traces").install()

_    = require("underscore")
Q    = require("q")
Path = require("path")

requireChai = (path) ->
  chaiBase = Path.dirname(require.resolve("chai"))
  require Path.join(chaiBase, path)

utils          = requireChai("lib/chai/utils")
assertions     = requireChai("lib/chai/core/assertions")
AssertionError = requireChai("node_modules/assertion-error")

chai   = "AssertionError": AssertionError
{flag} = require("./util.coffee")

requireChai("lib/chai/assertion")(chai, utils)

Assertion = chai.Assertion
Assertion.includeStack = true

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

  @promisify: (fn, name = null) -> (args...) ->
    if @hasPromises(args)
      task = @resolveFlags().then => Q.promised(fn).apply(this, args)
      barrierContext.waitFor(task, "expectation #{name}")
    else
      fn.apply(this, args)

    this

  flag: (name, value) ->
    if arguments.length == 1
      @__flags[name]
    else
      @__flags[name] = value

      this

  hasPromises: (args) ->
    values = _.values(flag(this) || {}).concat(args)
    _.any values, (v) -> Q.isPromise(v)

  resolveFlags: ->
    return Q(null) if flag(this, "hold")

    flags = _.keys(flag(this) || {})
    promises = _.map flags, (key) =>
      Q(flag(this, key)).then (value) => flag(this, key, value)

    Q.all(promises)

Expectation.addMethod "reject", (args...) ->
  fn = @_obj
  p = if _.isFunction(fn) then fn() else fn

  promise = p
    .then(-> ->)
    .catch((err) -> -> throw err)
    .then (resolvedFn) => flag(this, "object", resolvedFn).throw(args...)

  barrierContext.waitFor(promise)

  this

Assertion.addProperty.call Expectation, "hold", ->
  @__flags.hold = true

  this

assertions("Assertion": Expectation, utils)
