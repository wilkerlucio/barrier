_    = require("lodash")
W    = require("when")
util = require("../lib/util.coffee")

describe "Util", ->
  lazy "obj", -> a:1

  describe "reversibleChange", ->
    it "does nothing if the value is null", ->
      expect(-> util.reversibleChange(null, {})).not.throw

    it "return the plain object with null change", (obj) ->
      util.reversibleChange(obj, null)

      expect(obj).eql(a:1)

    it "mutates the object given valid values", (obj) ->
      util.reversibleChange(obj, b:2)

      expect(obj).eql(a:1,b:2)

    it "can revert the changes", (obj) ->
      revert = util.reversibleChange(obj, b:2)
      revert()

      expect(obj).eql(a:1)

    it "can revert by sending a block function", (obj) ->
      util.reversibleChange obj, b:2, ->
        expect(_.clone obj).eql(a:1,b:2)

      expect(obj).eql(a:1)

  describe "flag", ->
    {flag} = util

    # flag returns the obj when called with 3 arguments
    lazy "flagged", -> flag({}, "x", 1)

    it "returns null when sending all null", ->
      expect(flag()).null
      expect(flag(null)).null
      expect(flag(null, null)).null
      expect(flag(null, null, null)).null

    it "returns undefined if the flag don't exists on the user", ->
      expect(flag({}, "x")).undefined

    it "saves and loads the value", (flagged) ->
      expect(flag(flagged, "x")).eq(1)

    it "returns the flag hash when sending the object only", (flagged) ->
      expect(flag(flagged)).eql(x:1)

    it "has a property with the flag key", ->
      expect(flag.key).eq("__flags")

  describe "parentLookup", ->
    testContextLookup = (title, args..., expected) ->
      it title, -> expect(util.parentLookup(args...)).eql expected

    it "returns undefined for invalid inputs", ->
      expect(util.parentLookup(null, null)).undefined
      expect(util.parentLookup({}, null)).undefined
      expect(util.parentLookup(null, {})).undefined

    describe "context query", ->
      deepObject =
        x:
          a:1
        parent:
          y:
            a:2
          parent:
            x:
              a:3
            z:
              a:4

      testContextLookup "empty",             {},         "x", {}
      testContextLookup "simple",            {x:{a:1}},  "x", a:1
      testContextLookup "complex immediate", deepObject, "x", a:1
      testContextLookup "complex parent",    deepObject, "y", a:2
      testContextLookup "complex deep",      deepObject, "z", a:4

  describe "ancestorChain", ->
    {ancestorChain} = util

    it "returns a blank array when object is null", ->
      expect(ancestorChain()).eql []

    it "returns an array with the item if the object has no parent", ->
      expect(ancestorChain(x:1)).eql [{x:1}]

    it "chained lookup", ->
      root =
        x:1
        parent:
          y:2
          parent:
            z:3

      expect(ancestorChain(root)).deep.property("[0].x", 1)
      expect(ancestorChain(root)).deep.property("[1].y", 2)
      expect(ancestorChain(root)).deep.property("[2].z", 3)

  describe "functionArgNames", ->
    {functionArgNames} = util

    it "returns blank array when no arguments", ->
      expect(functionArgNames(->)).eql []

    it "returns the argument names", ->
      expect(functionArgNames((x, y)->)).eql ["x", "y"]

  describe "childrenIterator", ->
    {childrenIterator} = util

    it "throw a TypeError if the argument is not an array", ->
      expect(-> childrenIterator(null)).throw(TypeError, "subject must be an Array")

    it "iterates on a flat list", (sinon) ->
      childrenIterator([1, 2], spy = sinon.spy())
      expect(spy.args).eql [[1], [2]]

    it "goes down into children", (sinon) ->
      composed = children: [2, 3]
      childrenIterator([1, composed, 4], spy = sinon.spy())
      expect(spy.args).eql [[1],[composed],[2],[3],[4]]
