Case = requireLib("case")

describe "Case", ->
  lazy "scope", ->
    tests: []

  describe "initialize", ->
    it "fail to initialize without a parent", ->
      expect(-> new Case("", null, null)).throw /Test Case requires a parent/

  describe "#isPending", ->
    it "is pending when there is no block", (scope) ->
      expect(new Case("", null, scope).isPending()).true

    it "is not pending when the block is provided", (scope) ->
      expect(new Case("", (->), scope).isPending()).false
