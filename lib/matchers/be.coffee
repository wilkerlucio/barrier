module.exports = (engine) ->
  engine.defineMatcher "be",
    match: (actual, expected) -> actual == expected
