Q = require("q")

describe "async testing", ->
  it "supports async", ->
    done = @async()

    setTimeout ->
      expect(true).eq(true)
      done()
    , 40
