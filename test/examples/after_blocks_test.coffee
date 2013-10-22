Q = require("q")
{dv} = require("./test_helper.coffee")

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
