Q = require("q")

describe "async testing", ->
  it "supports async", ->
    done = @async()

    setTimeout Q.fbind ->
      expect(true).eq(true)
      done()
    , 40
