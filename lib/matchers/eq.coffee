_ = require("underscore")
s = JSON.stringify

module.exports = (engine) ->
  engine.defineMatcher "eq",
    match: (actual, expected) -> _.isEqual(actual, expected)
    errorMessage: (expected) -> "be equal to #{s expected}"
