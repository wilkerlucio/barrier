_ = require("underscore")
s = JSON.stringify

module.exports = (engine) ->
  engine.defineMatcher "haveProperty",
    match: (actual, property, value) ->
      if value?
        _.isEqual(actual[property], value)
      else
        actual[property]?

    errorMessage: (property, value) ->
      _.tap "have property #{s(property)}", (message) ->
        message += " with value #{s(value)}" if value?
