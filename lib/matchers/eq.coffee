_ = require("underscore")
Q = require("q")

module.exports = (engine) ->
  engine.defineMatcher "eq",
    match: (actual, expected) -> _.isEqual(actual, expected)
    failMessage: (actual, expected) -> "expected #{JSON.stringify(actual)} to be equal to #{JSON.stringify(expected)}"
    reverseFailMessage: (actual, expected) -> "expected #{JSON.stringify(actual)} to not be equal to #{JSON.stringify(expected)}"
