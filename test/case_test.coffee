require('./helper.coffee')

Case = requireLib("case")
{flag} = requireLib("util")

describe "Case", ->
  lazy "scope", -> children: []

  describe "initialize", ->
    it "fail to initialize without a parent", ->
      expect(-> new Case("", null, null)).throw /Test Case requires a parent/

    it "adds itself on the children list of the parent", (scope) ->
      tcase = new Case("", (->), scope)

      expect(scope.children).eql [tcase]

  describe "#isPending", ->
    it "is pending when there is no block", (scope) ->
      expect(new Case("", null, scope).isPending()).true

    it "is not pending when the block is provided", (scope) ->
      expect(new Case("", (->), scope).isPending()).false

    it "is pending if has the skip flag", (scope) ->
      test = new Case("", (->), scope)
      flag(test, "skip", true)

      expect(test.isPending()).true

  describe "#timeout", ->
    lazy "tcase", (scope) -> new Case("", null, scope)

    it "returns 2000 as default", (tcase) ->
      expect(tcase.timeout()).eq 2000

    it "uses the flag value if it's present", (tcase) ->
      flag(tcase, "timeout", 10)
      expect(tcase.timeout()).eq 10

  describe "#slow", ->
    lazy "tcase", (scope) -> new Case("", null, scope)

    it "returns 75 by default", (tcase) ->
      expect(tcase.slow()).eq 75

    it "can set the slow", (tcase) ->
      tcase.slow(100)
      expect(tcase.slow()).eq 100
