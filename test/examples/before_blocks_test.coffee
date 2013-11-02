{dv} = require("../support/dv.coffee")

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
