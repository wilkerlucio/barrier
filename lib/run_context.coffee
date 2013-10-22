_ = require("underscore")
Q = require("q")
Match = require("./matchers/index.coffee")

extractArgs = (fn) ->
  string = fn.toString()

  if match = string.match(/^function\s?\((.+?)\)/)
    _.map match[1].split(","), (word) -> word.replace(/^\s+|\s+$/g, '')
  else
    []

module.exports = class RunContext
  constructor: ->
    @match = Match
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
      block = scope.lazyFactory(arg)

      @lazys[arg] ||= @inject(block, scope).then (args) => block.apply(this, args)

    Q.all promises

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
