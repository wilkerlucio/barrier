_ = require("underscore")
Q = require("q")

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: ->
    context = barrierContext

    chain = @runList(@scope.allBeforeBlocks())
      .then => context.injectFunction(@block)

    context.pushTask(chain, "test main chain")

  runAfters: (next) ->
    @runList(@scope.allAfterEachBlocks())
      .then =>
        @runList(@scope.afterBlocks) unless next and next.scope == @scope

  runList: (remaining, defer = Q.defer()) ->
    if remaining.length > 0
      current = remaining.shift()

      try
        p = Q(current())
        p.then => @runList(remaining, defer)
        p.fail (err) -> defer.reject(err)
      catch err
        defer.reject(err)
    else
      defer.resolve(null)

    defer.promise

  flag: (name) ->
    return @__flags[name] unless !@__flags or _.isUndefined(@__flags[name])

    @scope.flag(name)

  fullTitle: ->
    "#{@scope.fullTitle()} #{@title}"
