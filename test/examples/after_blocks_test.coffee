require('../helper.coffee')

{dv} = require("../support/dv.coffee")

describe "After Blocks", ->
  allAfter = null
  eachAfter = null

  describe "let's nest", ->
    afterEach -> dv(null).then -> eachAfter = true

    it "don't change any on first", ->
      expect(allAfter).null
      expect(eachAfter).null

    it "change the after each", ->
      expect(allAfter).null
      expect(eachAfter).true

  describe "run order", ->
    value = null

    afterEach -> value = true

    it "wait to run the after blocks", ->
      done = @async()

      setTimeout ->
        expect(value).null
        done()
      , 50
