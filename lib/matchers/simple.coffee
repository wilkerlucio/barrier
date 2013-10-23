_ = require("underscore")
s = JSON.stringify

module.exports = (engine) ->
  engine.defineMatcher "true",
    match: (actual) -> actual == true
    errorMessage: -> "be true"

  engine.defineMatcher "false",
    match: (actual) -> actual == false
    errorMessage: -> "be false"

  engine.defineMatcher "null",
    match: (actual) -> actual == null
    errorMessage: -> "be null"
