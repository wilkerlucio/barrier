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

  before -> Q(true).delay(50).then -> out = "something"
  before -> out2 = out + " else"

  it "runs before block before the test", ->
    expect(out).eq("something")
    expect(out2).eq("something else")
