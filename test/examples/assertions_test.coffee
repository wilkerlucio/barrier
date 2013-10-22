Q = require("q")

describe "Assertions", ->
  describe "be", ->
    it "compares strings",  -> expect("string").be("string")
    it "compares booleans", -> expect(false).be(false)
    it "compares arrays",   -> expect([1, 2, 3]).not().be([1, 2, 3])

  describe "eq", ->
    it "comparing strings", -> expect("string").eq("string")
    it "comparing strings", -> expect("string").not().eq("other")
    it "compares booleans", -> expect(true).eq(true)
    it "compares lists",    -> expect(["a", "b", "c"]).eq(["a", "b", "c"])
    it "compares objects",  -> expect(a: 1).eq(a: 1)

  describe "haveProperty", ->
    it "check if the object has the property", ->
      expect(a: 1).haveProperty("a")

    it "check if the object has the property with value", ->
      expect(a: 1).haveProperty("a", 1)

    it "check if the object has the property with wrong value", ->
      expect(a: 1).not().haveProperty("a", 2)
