Q = require("q")

[Suite, Scope, {flag}] = requireLib("suite", "scope", "util")

describe "Suite", ->
  lazy "suite", -> new Suite()

  describe "init suite", ->
    it "has a global root scope", (suite) ->
      expect(suite.scopes).length(1)
      expect(suite.scopes[0]).a.instanceOf(Scope)

    it "has an empty list of tests", (suite) ->
      expect(suite.testCases).empty

  describe "scopes", ->
    it "creates with null title", (suite) ->
      expect(suite.describe()).property("title", null)
      expect(suite.describe(null)).property("title", null)

    it "creates a simple score", (suite) ->
      scope = suite.describe "pending"
      expect(scope).ok

    it "creates scopes and runs the block", (suite) ->
      ran = false
      suite.describe "something", -> ran = true

      expect(ran).true

    it "scope nesting", (suite) ->
      scope = test = null

      scope = suite.describe "", ->
        test = suite.test "", ->

      expect(test.parent).eq(scope)

    it "can mark flags", (suite) ->
      scope = suite.describe "", x:1, ->
      expect(flag(scope, "x")).eq(1)

    it "flags without block", (suite) ->
      scope = suite.describe "", x:1
      expect(flag(scope, "x")).eq(1)

  describe "creating tests", ->
    it "creates pending test", (suite) ->
      pending = suite.test "pending"
      expect(flag(pending, "pending")).true

    it "does simple tests creation", (suite) ->
      test = suite.test("x", ->)
      expect(test).ok

    it "creates a test with flags", (suite) ->
      test = suite.test "flagger", x:1, ->
      expect(flag(test, "x")).eq(1)

    it "inherit parent scopes flags", (suite) ->
      test = null

      suite.describe "nesting flags", x:1, ->
        suite.describe "more levels", z:3, ->
          test = suite.test "flag", y:2

      expect(flag(test, "y")).eq(2)
      expect(flag(test, "x")).eq(1)
      expect(flag(test, "z")).eq(3)

    it "resolves the flag promises", (suite) ->
      test = null

      suite.describe "promised flags on describe", x:Q(1), ->
        test = it "resolves the flag value", z:Q(2) ->

      expect(flag(test, "x")).eq(1)
      expect(flag(test, "z")).eq(2)
