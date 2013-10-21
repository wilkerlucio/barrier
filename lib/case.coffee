Q = require("q")

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: (context, next) ->
    before = @runList(@scope.allBeforeBlocks())

    context.pushTask(before)
    before.then =>
      blockP = Q @block.call(context)
      context.pushTask(blockP)
      blockP.then =>
        context.pushTask(@runList(@scope.allAfterEachBlocks()))
        context.pushTask(@runList(@scope.afterBlocks)) unless next and next.scope == @scope

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
