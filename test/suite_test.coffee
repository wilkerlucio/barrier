[Suite, Scope] = requireLib("suite", "scope")

describe "Suite", ->
  lazy "suite", -> new Suite()

  describe "init suite", ->
    it "has a global root scope", (suite) ->
      expect(suite.scopes).length(1)
      expect(suite.scopes[0]).a.instanceOf(Scope)

    it "has an empty list of tests", (suite) ->
      expect(suite.testCases).empty

  it "adds the it block into current scope", (suite) ->
    test = suite.test("x", b = ->)

    expect(suite.testCases).eql([test])
    expect(test.title).eq "x"
    expect(test.block).eq b
    expect(test.scope).eq suite.scopes[0]

  it "scope nesting", (suite) ->
    scope = test = null

    scope = suite.describe "", ->
      test = suite.test "", ->

    expect(test.scope).eq(scope)
