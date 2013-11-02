_ = require("underscore")
Q = require("q")
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

  describe "qSequence", ->
    qs = util.qSequence
    assertSequenceResult = (chain..., result) ->
      options = {}

      if chain.length > 1 and (result.interceptor? or result.prepare? or result.arg?)
        [options, result] = [result, chain.pop()]

      expect(qs(chain, options)).eq(result)

    lazy "fx",  -> -> "x"
    lazy "fy",  -> -> "y"
    lazy "fup", -> (x) -> x.toUpperCase()
    lazy "fid", -> _.identity

    it "returns a promise", ->
      expect(qs()).hold.respondTo("then")
      expect(qs([])).hold.respondTo("then")
      expect(qs(null)).hold.respondTo("then")

    it "runs once function", -> assertSequenceResult Q("x"), "x"

    it "returns value from last item", (fx, fy) -> assertSequenceResult fx, fy, "y"

    it "chain the results", (fx, fup) -> assertSequenceResult fx, fup, "X"

    it "can intercept the chain", (fx, fup) ->
      assertSequenceResult fx, fup, "XZz", interceptor: (value) -> value + "z"

    it "can prepare the promises", (fid) ->
      assertSequenceResult fid, "x", prepare: (fn) -> -> fn("x")

    it "handles returning promises on prepare", (fid) ->
      assertSequenceResult fid, "x", prepare: (fn) -> Q "x"

  describe "flag", ->
    flag = util.flag

    it "returns null when sending all null", ->
      expect(flag()).null
      expect(flag(null)).null
      expect(flag(null, null)).null
      expect(flag(null, null, null)).null

    it "returns undefined if the flag don't exists on the user", ->
      expect(flag({}, "x")).undefined

    it "saves and loads the value", ->
      obj = {}
      flag(obj, "x", 1)
      expect(flag(obj, "x")).eq(1)
