{childrenIterator, flag} = require("../util.coffee")

module.exports = (list) ->
  mustSkip = false

  childrenIterator list, (item) ->
    return if mustSkip

    mustSkip = true if flag(item, "only")

  return unless mustSkip

  childrenIterator list, (item) -> flag(item, "skip", true) unless flag(item, "only")
