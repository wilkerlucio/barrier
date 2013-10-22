Q = require("q")

describe "Simple Test", ->
  it "is true", ->
    expect(true).eq(true)

  it "is equal comparing strings", ->
    expect("something").eq("something")

  it "works sending promises for expect and matcher arguments", ->
    delayed = Q("value").delay(50)
    delayed2 = Q("value").delay(90)

    expect(delayed2).eq(delayed)
    expect(delayed).eq(delayed)

  it "can end returning a promise", ->
    Q("value").delay(50).then (v) ->
      expect(v).eq("value")

describe "Nested blocks", ->
  describe "I'm in", ->
    it "is true", ->

describe "Before Blocks", ->
  out = null
  out2 = null
  n = 0

  before -> Q(true).delay(50).then -> out = "something"
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
    afterEach -> Q(null).delay(50).then -> eachAfter = true

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
    lazy "user", -> Q("value2").delay(30)
    it "injects the value", (user) -> expect(user).eq("value2")

  describe "Lazy Dependencies", ->
    lazy "id", -> Q(10).delay(30)
    lazy "user", (id) -> Q("ID - #{id}").delay(20)

    it "injects the value", (user) -> expect(user).eq("ID - 10")

  describe "Lazy Caching", ->
    lazy "random", -> Q(Math.random()).delay(30)
    lazy "urand", (random) -> "U-#{random}"

    it "should use the same", (urand, random) ->
      expect(urand).eq("U-#{random}")

  describe "Lazy Lookup", ->
    lazy "onroot", -> Q("root").delay(20)
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
