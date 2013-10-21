module.exports = class Scope
  constructor: (@title, @parent) ->
    @beforeBlocks = []
    @afterBlocks = []

  fullTitle: ->
    if @parent
      "#{@parent.fullTitle()} #{@title}"
    else
      @title
