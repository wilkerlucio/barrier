_ = require("underscore")
Q = require("q")

class LazyBlock
  constructor: (@block, @persist, @name) ->

  value: ->
    context = barrierContext

    if @persist
      @_value ?= context.inject(@block).then (args) => @block.apply(context, args)
    else
      context.lazys[@name] ?= context.inject(@block).then (args) => @block.apply(context, args)

module.exports = class Scope
  constructor: (@title, @parent) ->
    @beforeBlocks = []
    @afterEachBlocks = []
    @afterBlocks = []
    @lazyBlocks = {}

  allBeforeBlocks: ->
    if @parent
      @parent.allBeforeBlocks().concat(@beforeBlocks)
    else
      @beforeBlocks.slice(0)

  allAfterEachBlocks: ->
    if @parent
      @parent.allAfterEachBlocks().concat(@afterEachBlocks)
    else
      @afterEachBlocks.slice(0)

  addLazy: (name, persist, block) ->
    [block, persist] = [persist, false] if arguments.length == 2

    @lazyBlocks[name] = new LazyBlock(block, persist, name)

  lazyFactory: (name) ->
    block = @lazyBlocks[name]
    block ||= @parent.lazyFactory(name) if @parent

    if _.isUndefined(block)
      throw new Error("Lazy dependency #{name} wasn't defined")

    block

  fullTitle: (titles = []) ->
    if @parent
      titles.unshift(@title)
      @parent.fullTitle(titles)
    else
      _.compact(titles).join(" ")
