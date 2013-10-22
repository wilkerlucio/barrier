_ = require("underscore")
Q = require("q")

extractArgs = (fn) ->
  string = fn.toString()

  if match = string.match(/^function\s?\((.+?)\)/)
    _.map match[1].split(","), (word) -> word.replace(/^\s+|\s+$/g, '')
  else
    []

module.exports = class Case
  constructor: (@title, @block, @scope) ->

  run: (context, next) ->
    before = @runList(@scope.allBeforeBlocks())
    context.pushTask(before)

    chain = before.then =>
      blockP = @runBlock(context)
      context.pushTask(blockP)
      blockP.then =>
        context.pushTask(@runList(@scope.allAfterEachBlocks()))
        context.pushTask(@runList(@scope.afterBlocks)) unless next and next.scope == @scope

    chain.catch (err) -> context.pushTask(Q.reject(err))

  runBlock: (context) ->
    args = extractArgs(@block)

    @scope.inject(args, context).then (args) => Q @block.apply(context, args)

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
