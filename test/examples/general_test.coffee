Q = require("q")

# helper function to generated a delayed value promise
dv = (value) -> Q(value).delay(Math.round(Math.random() * 100))

describe "Simple Test", ->
  it "is true", ->
    expect(true).eq(true)

  it "is equal comparing strings", ->
    expect("something").eq("something")

  it "works sending promises for expect and matcher arguments", ->
    delayed = dv("value")
    delayed2 = dv("value")

    expect(delayed2).eq(delayed)
    expect(delayed).eq(delayed)

  it "can end returning a promise", ->
    dv("value").then (v) ->
      expect(v).eq("value")

describe "Nested blocks", ->
  describe "I'm in", ->
    it "is true", ->

describe "Before Blocks", ->
  out = null
  out2 = null
  n = 0

  before -> dv(true).then -> out = "something"
  before -> out2 = out + " else"

  before -> n += 1
  beforeEach -> n += 1

  it "runs before block before the test", ->
    expect(out).eq("something")
    expect(out2).eq("something else")
    expect(n).eq(2)

  describe "inner most scopes with before", ->
    beforeEach -> n += 2

    it "runs external and internal", ->
      expect(n).eq(5)

  it "runs before each on each test", ->
    expect(n).eq(6)

describe "After Blocks", ->
  allAfter = null
  eachAfter = null

  describe "let's nest", ->
    after -> allAfter = true
    afterEach -> dv(null).then -> eachAfter = true

    it "don't change any on first", ->
      expect(allAfter).eq(null)
      expect(eachAfter).eq(null)

    it "change the after each", ->
      expect(allAfter).eq(null)
      expect(eachAfter).eq(true)

  it "change all", ->
    expect(allAfter).eq(true)
    expect(eachAfter).eq(true)

describe "Lazy Blocks", ->
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

describe "async testing", ->
  it "supports async", ->
    done = @async()

    setTimeout ->
      expect(true).eq(true)
      done()
    , 40

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
