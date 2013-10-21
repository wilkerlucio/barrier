Q = require("q")

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: (context) ->
    before = @runBefore()
    context.pushTask(before)
    before.then => context.pushTask(Q @block.call(context))

  runBefore: (remaining = @scope.allBeforeBlocks(), defer = Q.defer()) ->
    if remaining.length > 0
      current = remaining.shift()

      try
        p = Q(current.run())
        p.then => @runBefore(remaining, defer)
        p.fail (err) -> defer.reject(err)
      catch err
        defer.reject(err)
    else
      defer.resolve(null)

    defer.promise

  fullTitle: ->
    "#{@scope.fullTitle()} #{@title}"
