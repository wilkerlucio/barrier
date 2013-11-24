_    = require("underscore")
util = require("./util.coffee")
fk   = util.flag.key

class LazyBlock
  constructor: (@block, @persist, @name, @scope) ->

module.exports = class Scope
  constructor: (@title, @parent) ->
    @[fk] = _.clone(@parent[fk]) if @parent

    @lazyBlocks      = {}
    @children        = []
    @tests           = []

    @parent.children.push(this) if @parent

  hook: (context, block) ->
    ctx = @[context] || (@[context] = [])
    return ctx unless block?
    ctx.push(block); block

  addLazy: (name, persist, block) ->
    [block, persist] = [persist, false] if arguments.length == 2

    @lazyBlocks[name] = new LazyBlock(block, persist, name, this)

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
