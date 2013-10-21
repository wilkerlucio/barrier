module.exports = class Scope
  constructor: (@title, @parent) ->
    @beforeBlocks = []
    @afterEachBlocks = []
    @afterBlocks = []

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

  fullTitle: ->
    if @parent
      "#{@parent.fullTitle()} #{@title}"
    else
      @title
