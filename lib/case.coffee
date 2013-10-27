_ = require("underscore")
Q = require("q")

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: ->
    context = barrierContext
    before = @runList(@scope.allBeforeBlocks())

    chain = before
      .then =>
        @runBlock(context)

    context.pushTask(chain, "test main chain")

  runAfters: (next) ->
    @runList(@scope.allAfterEachBlocks())
      .then =>
        @runList(@scope.afterBlocks) unless next and next.scope == @scope

  runBlock: (context) ->
    context.inject(@block).then (args) => Q @block.apply(context, args)

  runList: (remaining, defer = Q.defer()) ->
    if remaining.length > 0
      current = remaining.shift()

      try
        p = Q(current.run())
        p.then => @runList(remaining, defer)
        p.fail (err) -> defer.reject(err)
      catch err
        defer.reject(err)
    else
      defer.resolve(null)

    defer.promise

  fullTitle: ->
    "#{@scope.fullTitle()} #{@title}"
