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

    it "returns a promise", ->
      expect(qs()).hold.respondTo("then")
      expect(qs([])).hold.respondTo("then")
      expect(qs(null)).hold.respondTo("then")

    it "runs once function", ->
      f = -> Q("x")

      expect(qs [f]).eq("x")

    it "returns value from last item", ->
      f = -> "x"
      f2 = -> "y"

      expect(qs [f, f2]).eq "y"

    it "chain the results", ->
      f = -> "x"
      f2 = (x) -> x.toUpperCase()

      expect(qs [f, f2]).eq "X"

    it "can intercept the chain", ->
      f = -> "x"
      f2 = (x) -> x.toUpperCase()

      promise = qs [f, f2], interceptor: (value) -> value + "z"

      expect(promise).eq "XZz"

    it "can prepare the promises", ->
      f = (x) -> x

      promise = qs [f], prepare: (fn) -> -> fn("x")

      expect(promise).eq "x"

    it "handles returning promises on prepare", ->
      f = (x) -> x

      promise = qs [f], prepare: (fn) -> Q("x")

      expect(promise).eq "x"

