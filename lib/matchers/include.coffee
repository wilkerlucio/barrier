_ = require("underscore")
s = JSON.stringify

module.exports = (engine) ->
  engine.defineMatcher "include",
    match: (list, value) -> _.contains(list, value)
    errorMessage: (value) -> "include #{s value}"
