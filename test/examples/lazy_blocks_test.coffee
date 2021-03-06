require('../helper.coffee')

{dv} = require("../support/dv.coffee")

describe "Example Lazy Blocks", ->
  describe "Simple Lazy", ->
    lazy "user", -> "value"
    it "injects the value", (user) -> expect(user).eq("value")

  describe "Promised Lazy", ->
    lazy "user", -> dv("value2")
    it "injects the value", (user) -> expect(user).eq("value2")

  describe "Lazy Dependencies", ->
    lazy "id", -> dv(10)
    lazy "user", (id) -> dv("ID - #{id}")

    it "injects the value", (user) -> expect(user).eq("ID - 10")

  describe "Lazy Caching", ->
    lazy "random", -> dv(Math.random())
    lazy "urand", (random) -> "U-#{random}"

    it "should use the same", (urand, random) ->
      expect(urand).eq("U-#{random}")

  describe "Lazy Lookup", ->
    lazy "onroot", -> dv("root")
    lazy "onchild", -> "rootChild"

    describe "inner block", ->
      lazy "onchild", -> "child"

      it "loads the child first", (onchild) -> expect(onchild).eq("child")
      it "loads from proper parents", (onroot) -> expect(onroot).eq("root")

  describe "Lazy context cache", ->
    lazy "ctx", true, -> {n: 1}

    it "run here", (ctx) ->
      ctx.x = 5

    it "accumulates", (ctx) ->
      expect(ctx).property("x", 5)

  describe "lazy on before blocks", ->
    lazy "blue", -> "meth"

    val = null

    beforeEach (blue) -> val = blue

    it "injects on before", -> expect(val).eq("meth")
