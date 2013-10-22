Q = require("q")
{dv} = require("./test_helper.coffee")

describe "Simple Test", ->
  it "is true", ->
    expect(true).eq(true)

  it "is false", ->
    expect(false).eq(false)

  it "is null", ->
    expect(null).eq(null)

  it "is undefined", ->
    expect(undefined).eq(undefined)

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
