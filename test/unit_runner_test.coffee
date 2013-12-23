_          = require("lodash")
W          = require("when")
wfn        = require("when/function")
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

    unit.run().then -> expect(ran, "block must had ran").true

  it "sets the duration of the test", ->
    ran = false
    block = -> ran = true
    scope = new Scope("")
    test = new Case("", block, scope)
    unit = new UnitRunner(test)

    unit.run().then -> expect(test.duration).not.undefined

  it "fails when the block raises an error", ->
    block = -> throw "err"
    scope = new Scope("")
    test = new Case("", block, scope)
    unit = new UnitRunner(test)

    unit.run().otherwise (err) -> expect(err).eql "err"

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

      unit.run().otherwise ->
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

      test = new Case("", (-> expect(true).false), scope)
      unit = new UnitRunner(test)

      p = unit.run()
      p.otherwise ->
        expect(seq, "before blocks must had ran in order").eql([1, 2])

    it "still fails when the after block fails", ->
      seq = []

      scope = new Scope("")
      scope.hook "beforeEach", -> seq.push(1)
      scope.hook "afterEach", -> throw 'err'

      test = new Case("", (-> seq.push(2)), scope)
      unit = new UnitRunner(test)

      unit.run().otherwise (e) ->
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

      unit.run().otherwise (e) ->
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
      scope.addLazy "x", -> W("y")

      test = new Case("", ((x) -> seq.push(x)), scope)
      unit = new UnitRunner(test)

      unit.run().then (e) ->
        expect(seq, "lazy must had loaded").eql(["y"])

    it "raises an error when ask for undefined lazy", ->
      scope = new Scope("")
      test = new Case("", ((x) -> null), scope)
      unit = new UnitRunner(test)

      expect(unit.run()).hold.reject("Lazy block 'x' wasn't defined")

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

    describe "lazy override parent lookup", ->
      it "can extend parent lazy definitions", ->
        scope = new Scope("Lazy parent scope lookup")
        scope.addLazy "x", -> 1

        innerScope = new Scope("inner scope", scope)
        innerScope.addLazy "x", (x) -> x + 2

        testBlock = (x) -> expect(x).eq(3)
        test = new Case("", testBlock, innerScope)

        new UnitRunner(test).run()

      it "raises error if there is no parent definition", ->
        scope = new Scope("Lazy parent scope lookup")

        innerScope = new Scope("inner scope", scope)
        innerScope.addLazy "x", (x) -> x + 2

        testBlock = (x) -> expect(x).eq(3)
        test = new Case("", testBlock, innerScope)

        expect(new UnitRunner(test).run()).hold.reject(Error, "No more parent 'x' after 1 depth")

    it "works on beforeEach blocks", ->
      seq = []

      scope = new Scope("")
      scope.addLazy "x", -> "y"
      scope.hook "beforeEach", (x) -> seq.push(x)

      test = new Case("", (->), scope)
      unit = new UnitRunner(test)

      unit.run().then (e) ->
        expect(seq, "lazy must had loaded").eql(["y"])

    it "works on afterEach blocks", ->
      seq = []

      scope = new Scope("")
      scope.addLazy "x", -> "y"
      scope.hook "afterEach", (x) -> seq.push(x)

      test = new Case("", (->), scope)
      unit = new UnitRunner(test)

      unit.run().then (e) ->
        expect(seq, "lazy must had loaded").eql(["y"])

  describe "parallel wait", ->
    delayedCall = (wait, fn) ->
      defer = W.defer()
      setTimeout ->
        defer.resolve(wfn.call(fn))
      , wait
      defer.promise

    it "waits for added parallel tasks", ->
      seq = []
      scope = new Scope("")
      scope.hook "afterEach", -> seq.push(2)
      test = new Case("", (->
        @waitFor delayedCall(10, -> seq.push(1))

        null
      ), scope)

      unit = new UnitRunner(test)
      unit.run().then ->
        expect(seq, "waited on the test before the next").eql([1, 2])

    it "catches error on parallel runs", ->
      scope = new Scope("")
      test = new Case("", (->
        @waitFor delayedCall(10, -> throw "err")

        null
      ), scope)

      unit = new UnitRunner(test)
      unit.run().otherwise (e) ->
        expect(e).eq "err"

  describe "async", ->
    it "fires async calls and wait for the done", ->
      seq = []
      scope = new Scope("")
      scope.hook "afterEach", -> seq.push(2)
      test = new Case("", (->
        done = @async()

        setTimeout ->
          seq.push(1)
          done()
        , 10

        null
      ), scope)

      unit = new UnitRunner(test)
      unit.run().then ->
        expect(seq, "waited on the test before the next").eql([1, 2])

    it "catches errors into async", ->
      scope = new Scope("")
      test = new Case("", (->
        done = @async()
        setTimeout ->
          done("err")
        , 10

        null
      ), scope)

      unit = new UnitRunner(test)
      unit.run().otherwise (e) ->
        expect(e).eq "err"

  describe "globals", ->
    it "sets the expect global", ->
      expectVar = false

      scope = new Scope("")
      test = new Case("", (->
        expectVar = expect == unit.expect
      ), scope)

      unit = new UnitRunner(test)
      unit.run().then (e) ->
        expect(expectVar, "global expect is set correctly").true

    it "sets the barrierContext global", ->
      expectVar = false

      scope = new Scope("")
      test = new Case("", (->
        expectVar = barrierContext == unit
      ), scope)

      unit = new UnitRunner(test)
      unit.run().then (e) ->
        expect(expectVar, "global barrierContext is set correctly").true
