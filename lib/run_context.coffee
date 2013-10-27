_ = require("underscore")
Q = require("q")

extractArgs = (fn) ->
  string = fn.toString()

  if match = string.match(/^function\s?\((.+?)\)/)
    _.map match[1].split(","), (word) -> word.replace(/^\s+|\s+$/g, '')
  else
    []

module.exports = class RunContext
  constructor: ->
    @tasks = []
    @errors = []
    @lazys = {}

    @defer = Q.defer()
    @done = @defer.promise

  pushTask: (task) ->
    task.catch(@pushError)
    task.finally(@taskDone)
    @tasks.push(task)

    task

  pushError: (err) => @errors.push(err)

  inject: (fn, scope) ->
    args = extractArgs(fn)

    promises = _.map args, (arg) =>
      lazy = scope.lazyFactory(arg)
      lazy.value(this, scope)

    @pushTask Q.all(promises)

  taskDone: =>
    if @allTasksDone()
      if @errors.length > 0
        @defer.reject(@errors[0])
      else
        @defer.resolve(null)

  allTasksDone: -> _.every @tasks, (task) -> !task.isPending()

  async: ->
    defer = Q.defer()
    @pushTask(defer.promise)

    -> defer.resolve(null)
