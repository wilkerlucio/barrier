_ = require("underscore")

class SimpleMatcher
  constructor: (@matcher) ->
  match: (args...) -> @matcher(args...)

class MatcherEngine
  constructor: ->
    @matchers = {}

  defineMatcher: (name, matcher) ->
    matcher = {match: matcher} if _.isFunction(matcher)

    matcher = _.extend
      failMessage: (actual) -> "expected #{actual} to #{name}"
      reverseFailMessage: (actual) -> "expected #{actual} to not #{name}"
    , matcher

    @matchers[name] = matcher

  install: (expectation) ->
    for name, matcher of @matchers
      do (name, matcher) ->
        expectation[name] = (args...) -> expectation.runMatcher(matcher, args)

engine = new MatcherEngine()

require("./be")(engine)
require("./eq")(engine)

engine.defineMatcher "haveProperty", (actual, property, value) ->
  if value? then _.isEqual(actual[property], value) else actual[property]?

module.exports = engine
