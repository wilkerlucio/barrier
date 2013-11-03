_  = require("underscore")
Q  = require("q")
fk = require("./util.coffee").flag.key

class LazyBlock
  constructor: (@block, @persist, @name) ->

  value: ->
    context = barrierContext

    if @persist
      @_value ?= context.injectFunction(@block)
    else
      context.lazys[@name] ?= context.injectFunction(@block)

module.exports = class Scope
  constructor: (@title, @parent) ->
    @[fk] = _.clone(@parent[fk]) if @parent

    @lazyBlocks      = {}
    @beforeBlocks    = []
    @afterEachBlocks = []
    @afterBlocks     = []
    @children        = []
    @tests           = []

    @parent.children.push(this) if @parent

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

  flag: (name) ->
    return @__flags[name] unless !@__flags or _.isUndefined(@__flags[name])
    return @parent.flag(name) if @parent

    undefined

  fullTitle: (titles = []) ->
    if @parent
      titles.unshift(@title)
      @parent.fullTitle(titles)
    else
      _.compact(titles).join(" ")

  toJSON: ->
    title: @title
    lazy: @lazyBlocks
    before: @beforeBlocks
    afterEach: @afterEachBlocks
    after: @afterBlocks
    children: @children
