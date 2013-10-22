_ = require("underscore")
Q = require("q")

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

  addLazy: (name, block) -> @lazyBlocks[name] = block

  lazyFactory: (name) ->
    block = @lazyBlocks[name]
    block ||= @parent.lazyFactory(name) if @parent

    if _.isUndefined(block)
      throw new Error("Lazy dependency #{name} wasn't defined")

    block

  fullTitle: ->
    if @parent
      "#{@parent.fullTitle()} #{@title}"
    else
      @title
