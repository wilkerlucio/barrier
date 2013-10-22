_ = require("underscore")
Q = require("q")
Match = require("./matchers")

module.exports = class RunContext
  constructor: ->
    @match = Match
    @tasks = []
    @errors = []

    @defer = Q.defer()
    @done = @defer.promise

  pushTask: (task) ->
    task = task.timeout(2000)
    task.catch(@pushError)
    task.finally(@taskDone)
    @tasks.push(task)

    task

  pushError: (err) =>
    @errors.push(err)

  taskDone: =>
    if @allTasksDone()
      if @errors.length > 0
        @defer.reject(@errors[0])
      else
        @defer.resolve(null)

  allTasksDone: -> _.every @tasks, (task) -> !task.isPending()
