Barrier
=======

A test framework that embraces promises for real

Installation
------------

```
npm install barriertest
```

Basic Testing
-------------

This part describes the regular sync tests.

Barrier uses RSpec-like syntax to describe tests, as so:

```coffee
describe "MyObject", ->
  it "sums two numbers", ->
    expect(sum(2, 3)).to.eq(5)
```

You can nest describe blocks as you like:

```coffee
describe "MyObject", ->
  describe "some internal", ->
    it "do something", ->
      expect(something()).to.eq(true)
```

We support `before`, `beforeEach`, `after` and `afterEach` clauses:

```coffee
describe "MyObject", ->
  someVar = null

  before -> someVar = "hello"

  it "must set someVar", ->
    expect(someVar).to.eq("hello")
```

Also, we support lazy blocks for dependency injection:

```coffee
describe "MyObject", ->
  lazy "value", -> 50

  it "loads the value", (value) ->
    expect(value).to.eq(50)
```

Note that the we do a reflection on the function to extract the variable name, them we lookup and build it for each test.

And you can inject dependencies on each other:

```coffee
describe "MyObject", ->
  lazy "value", -> 50
  lazy "value2", (value) -> value + 10

  it "loads the values", (value2) ->
    expect(value2).to.eq(60)
```

Async Testing
-------------

For basic async testing, you can call `async` into the current object to make the test wait:

```coffee
describe "Awesome", ->
  it "supports async testing", ->
    done = @async()

    setTimeout ->
      expect(true).to.be.true()
      done()
    , 50
```
