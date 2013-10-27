_ = require("underscore")
Q = require("q")

extractArgs = (fn) ->
  string = fn.toString()

  if match = string.match(/^function\s?\((.+?)\)/)
    _.map match[1].split(","), (word) -> word.replace(/^\s+|\s+$/g, '')
  else
    []

module.exports = class RunContext
  constructor: (@case) ->
    @tasks = []
    @lazys = {}

    @defer = Q.defer()
    @done = @defer.promise

  pushTask: (task, description = null) ->
    task.description = description
    task.finally(@taskDone)
    @tasks.push(task)

    task

  inject: (fn, scope) ->
    args = extractArgs(fn)

    promises = _.map args, (arg) =>
      lazy = scope.lazyFactory(arg)
      lazy.value(this, scope)

    Q.all(promises)

  taskDone: =>
    if @done.isPending() and @allTasksDone()
      error = _.find @tasks, (t) -> t.isRejected()

      if error
        @defer.reject(error.inspect().reason)
      else
        @defer.resolve(null)

  allTasksDone: -> _.every @tasks, (task) -> !task.isPending()

  async: ->
    defer = Q.defer()
    @pushTask(defer.promise, "async call")

    -> defer.resolve(null)
