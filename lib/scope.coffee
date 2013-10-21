module.exports = class Scope
  constructor: (@title, @parent) ->
    @beforeBlocks = []
    @afterBlocks = []

  allBeforeBlocks: ->
    if @parent
      @parent.allBeforeBlocks().concat(@beforeBlocks)
    else
      @beforeBlocks

  fullTitle: ->
    if @parent
      "#{@parent.fullTitle()} #{@title}"
    else
      @title
