require('../helper.coffee')

W = require("when")
{dv} = require("../support/dv.coffee")

describe "Assertions", ->
  describe "eq", ->
    it "comparing strings", -> expect("string").eq("string")
    it "comparing strings", -> expect("string").not.eq("other")
    it "compares booleans", -> expect(true).true
    it "compares lists",    -> expect(["a", "b", "c"]).eql(["a", "b", "c"])
    it "compares objects",  -> expect(a: 1).eql(a: 1)

  describe "property", ->
    it "check if the object has the property", ->
      expect(a: 1).have.property("a")

    it "check if the object has the property with value", ->
      expect(a: 1).have.property("a", 1)

    it "check if the object has the property with wrong value", ->
      expect(a: 1).not.have.property("a", 2)

  describe "work with members", ->
    it "check for members", ->
      expect([1, 2, 3]).to.include.members(dv([1, 3]))

  describe "include", ->
    it "is true when the element is contained on the list", ->
      expect(["Walter", "Batman"]).include("Batman")

    it "is false when the element is not contained on the list", ->
      expect([1, 2, 3]).to.not.include(5)

  describe "true", ->
    it "valid for true", -> expect(true).to.be.true
    it "invalid for false", -> expect(false).to.not.be.true

  describe "false", ->
    it "valid for false", -> expect(false).false
    it "invalid for true", -> expect(true).not.false

  describe "null", ->
    it "valid for null", -> expect(null).null
    it "invalid for true", -> expect(true).not.null
    it "invalid for false", -> expect(false).not.null
    it "invalid for undefined", -> expect(undefined).not.null
    it "works with promise", -> expect(W(null)).null

  describe "reject", ->
    it "assert that a promise is rejected", ->
      expect(-> W.reject("error")).reject()
