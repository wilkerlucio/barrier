_ = require("underscore")

class SimpleMatcher
  constructor: (@matcher) ->
  match: (args...) -> @matcher(args...)

class MatcherEngine
  constructor: ->
    @matchers = {}

  defineMatcher: (name, matcher) ->
    @matchers[name] = matcher

  install: (expectation) ->
    for name, matcher of @matchers
      do (name, matcher) ->
        expectation[name] = (args...) -> expectation.runMatcher(matcher, args)

engine = new MatcherEngine()

require("./eq")(engine)

module.exports = engine
