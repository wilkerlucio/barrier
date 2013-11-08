_    = require("underscore")
Q    = require("q")
util = require("./util.coffee")
fk   = util.flag.key

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

  hook: (context, block) ->
    ctx = @[context] || (@[context] = [])
    return ctx unless block?
    ctx.push(block); block

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
    block = util.parentLookup(this, "lazyBlocks", name)

    if _.isUndefined(block)
      throw new Error("Lazy dependency #{name} wasn't defined")

    block

  fullTitle: (titles = []) ->
    if @parent
      titles.unshift(@title)
      @parent.fullTitle(titles)
    else
      _.compact(titles).join(" ")

  toJSON: ->
    title:     @title
    lazy:      @lazyBlocks
    before:    @beforeBlocks
    afterEach: @afterEachBlocks
    after:     @afterBlocks
    children:  @children
