_          = require("underscore")
Q          = require("q")
Scope      = requireLib("scope")
Case       = requireLib("case")
UnitRunner = requireLib("unit_runner")

describe "Test Runner", ->
  it "raises error if no test is given", ->
    expect(-> new UnitRunner()).throw

  it "the run method returns a promise", ->
    ran = false
    block = -> ran = true
    scope = new Scope("")
    test = new Case("", block, scope)
    unit = new UnitRunner(test)

    expect(unit.run(), "block must had ran").true

  describe "beforeEach blocks", ->
    it "must run the before blocks on parent ancestors", ->
      seq = []
      root = new Scope("")
      scope = new Scope("", root)

      root.hook "beforeEach", -> seq.push(1)
      scope.hook "beforeEach", -> seq.push(3)
      scope.hook "beforeEach", -> seq.push(4)
      root.hook "beforeEach", -> seq.push(2)

      test = new Case("", (-> seq.push(5)), scope)
      unit = new UnitRunner(test)

      unit.run().then ->
        expect(seq, "before blocks must had ran in order").eql([1, 2, 3, 4, 5])

    it "fail on before blocks", ->
      seq = []
      scope = new Scope("")
      scope.hook "beforeEach", -> seq.push(1)
      scope.hook "beforeEach", -> throw 'err'
      test = new Case("", (-> seq.push(2)), scope)
      unit = new UnitRunner(test)

      unit.run().catch ->
        expect(seq, "before blocks must had ran in order").eql([1])

  describe "afterEach blocks", ->
    it "must run the after blocks on parent", ->
      seq = []
      scope = new Scope("")
      scope.hook "afterEach", -> seq.push(2)
      scope.hook "afterEach", -> seq.push(3)
      test = new Case("", (-> seq.push(1)), scope)
      unit = new UnitRunner(test)

      unit.run().then ->
        expect(seq, "before blocks must had ran in order").eql([1, 2, 3])

    it "runs after blocks even on fail", ->
      seq = []

      scope = new Scope("")
      scope.hook "beforeEach", -> seq.push(1)
      scope.hook "afterEach", -> seq.push(2)

      test = new Case("", (-> throw 'err'), scope)
      unit = new UnitRunner(test)

      unit.run().fail ->
        expect(seq, "before blocks must had ran in order").eql([1, 2])

    it "still fails when the after block fails", ->
      seq = []

      scope = new Scope("")
      scope.hook "beforeEach", -> seq.push(1)
      scope.hook "afterEach", -> throw 'err'

      test = new Case("", (-> seq.push(2)), scope)
      unit = new UnitRunner(test)

      unit.run().fail (e) ->
        expect(e).eq('err')
        expect(seq, "before blocks must had ran in order").eql([1, 2])

    it "all afterEach still runs on fails", ->
      seq = []

      scope = new Scope("")
      scope.hook "beforeEach", -> seq.push(1)
      scope.hook "afterEach", -> seq.push(2)
      scope.hook "afterEach", -> throw 'err 2'
      scope.hook "afterEach", -> seq.push(3)

      test = new Case("", (-> throw 'err'), scope)
      unit = new UnitRunner(test)

      unit.run().fail (e) ->
        expect(e).eq 'err'
        expect(seq, "before blocks must had ran in order").eql([1, 2, 3])

  describe "lazy blocks", ->
    it "loads the lazy blocks when requested", ->
      seq = []

      scope = new Scope("")
      scope.addLazy "x", -> "y"

      test = new Case("", ((x) -> seq.push(x)), scope)
      unit = new UnitRunner(test)

      unit.run().then (e) ->
        expect(seq, "lazy must had loaded").eql(["y"])

    it "works with lazy promises", ->
      seq = []

      scope = new Scope("")
      scope.addLazy "x", -> Q("y")

      test = new Case("", ((x) -> seq.push(x)), scope)
      unit = new UnitRunner(test)

      unit.run().then (e) ->
        expect(seq, "lazy must had loaded").eql(["y"])

    it "raises an error when ask for undefined lazy", ->
      scope = new Scope("")
      test = new Case("", ((x) -> null), scope)
      unit = new UnitRunner(test)

      unit.run().fail (e) ->
        expect(e).eq "Lazy block 'x' wasn't defined"

    it "can use lazys on lazys", ->
      seq = []

      scope = new Scope("")
      scope.addLazy "x", (y) -> y
      scope.addLazy "y", -> "z"

      test = new Case("", ((x) -> seq.push(x)), scope)
      unit = new UnitRunner(test)

      unit.run().then (e) ->
        expect(seq, "lazy must had loaded").eql(["z"])

    it "injected blocks cache by runner", ->
      callCount = 0

      scope = new Scope("")
      scope.addLazy "x", (y) -> y
      scope.addLazy "y", -> callCount += 1

      test = new Case("", ((x, y) -> null), scope)
      unit = new UnitRunner(test)
      unit2 = new UnitRunner(test)

      unit.run().then ->
        unit2.run().then ->
          expect(callCount, "lazy must had cached").eql(2)

    it "can cache by lazy", ->
      callCount = 0

      scope = new Scope("")
      scope.addLazy "x", (y) -> y
      scope.addLazy "y", true, -> callCount += 1

      test = new Case("", ((x, y) -> null), scope)
      unit = new UnitRunner(test)
      unit2 = new UnitRunner(test)

      unit.run().then ->
        unit2.run().then ->
          expect(callCount, "lazy must had cached").eql(1)
