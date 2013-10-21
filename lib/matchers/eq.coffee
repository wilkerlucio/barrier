Q = require("q")

module.exports = (engine) ->
  engine.defineMatcher "eq", (current, expected) ->
    if current != expected
      throw new Error("expected '#{current}' to be equals to '#{expected}'")
