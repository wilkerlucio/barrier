_ = require("underscore")
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
