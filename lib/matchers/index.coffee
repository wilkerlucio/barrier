_ = require("underscore")

class MatcherEngine
  constructor: ->
    @matchers = {}

  defineMatcher: (name, matcher) ->
    matcher = {match: matcher} if _.isFunction(matcher)

    matcher = _.extend
      errorMessage: (args...) -> name + " " + args.join(" ")
      failMessage: (actual, args...) -> "expected #{actual} to #{@errorMessage(args...)}"
      reverseFailMessage: (actual, args...) -> "expected #{actual} to not #{@errorMessage(args...)}"
    , matcher

    @matchers[name] = matcher

  install: (expectation) ->
    for name, matcher of @matchers
      do (name, matcher) ->
        expectation[name] = (args...) -> expectation.runMatcher(matcher, args)

engine = new MatcherEngine()

require("./simple.coffee")(engine)
require("./be.coffee")(engine)
require("./eq.coffee")(engine)
require("./have_property.coffee")(engine)

module.exports = engine
