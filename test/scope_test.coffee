_     = require("underscore")
sinon = require("sinon")
Scope = requireLib("scope")
util  = requireLib("util")
S     = JSON.stringify

describe "Scope", ->
  lazy "root", -> new Scope("root")

  describe "initialize", ->
    it "saves title and parent", (root)->
      scope = new Scope("t", root)

      expect(scope.title).eq("t")
      expect(scope.parent).eq(root)
      expect(root.children).eql [scope]

  describe "hooks", ->
    it "empty calls", (root) ->
      expect(root.hook()).eql([])
      expect(root.hook(null)).eql([])
      expect(root.hook("")).eql([])

    it "saves and reads hooks", (root) ->
      fn = ->
      expect(root.hook("before", fn)).eq(fn)
      expect(root.hook("before")).eql [fn]

  describe "#addLazy", ->
    testInvalidArgs = (args...) ->
      it "throw error with args #{S args}", (root) ->
        expect(-> root.addLazy(args...)).throw

    testInvalidArgs()
    testInvalidArgs null
    testInvalidArgs null, null
    testInvalidArgs "x", null
    testInvalidArgs null, ->

  describe "#lazyFactory", ->
    it "raises error when the lazy is not defined", (root) ->
      expect(-> root.lazyFactory("x")).throw "Lazy dependency x wasn't defined"

    it "returns the block if it's present", (root) ->
      root.addLazy "x", (f = -> 1)
      lazy = root.lazyFactory("x")
      expect(lazy).property "block", f
      expect(lazy).property "persist", false
      expect(lazy).property "name", "x"
