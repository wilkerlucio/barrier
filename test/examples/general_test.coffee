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

allAfter = null
eachAfter = null

describe "After Blocks", ->
  describe "let's nest", ->
    after -> allAfter = true
    afterEach -> eachAfter = true

    it "don't change any on first", ->
      expect(allAfter).eq(null)
      expect(eachAfter).eq(null)

    it "change the after each", ->
      expect(allAfter).eq(null)
      expect(eachAfter).eq(true)

  it "change all", ->
    expect(allAfter).eq(true)
    expect(eachAfter).eq(true)
