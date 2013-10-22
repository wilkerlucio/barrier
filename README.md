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

Despites the support on simple async testing, we really recommend you to use promises instead, as described on the next section.

Promises Testing
----------------

We recognize that there is a lot of async code into Node, and also, we recognize that promises have a great value in helping to write better async code.

That's why Barrier supports and recommends promises usage over the entire testing process.

But actually there is not much to say about the usage, because it's just transparent! You can just use promises as values and we handle the rest!

Check some examples:

```coffee
describe "Using Promises", ->
  it "can use promises as values on expectations", ->
    # imagine that loadUser and fetchRemoteAge are functions that returns
    # promises that will eventually handle de values
    expect(loadUser(30)).to.haveProperty("age", fetchRemoteAge())
```

Also, if your test returns a promise, the runner will wait for it:

```coffee
describe "Delaying the runner", ->
  it "will wait for my promise", ->
    Q("value").delay(30).then (v) ->
      expect(v).to.eq("value") # and that's it, Barrier will do the async handling magic
```

Before and after blocks does the same, if you return promises on they, the runner will wait before going on:

```coffee
describe "Before promise me...", ->
  user = null
  userDecorated = null

  before -> loadUser().then (u) -> user = u
  # note that before blocks run in series, so, it's safe to expect that previous
  # before blocks are done
  before -> userDecorated = decorateUser(user)

  it "is awesome", -> expect(userDecorated).to.not().be.null()
```

But remember about Lazy Attributes? They can be promises too!

```coffee
describe "Lazy Promises", ->
  lazy "user", -> findUserOnDB()

  it "will load the promise and inject it!", (user) ->
    expect(user.name).to.eq("sir")
```

And even better, you can do it while injecting lazy dependencies!

```coffee
describe "Lazy Promises Dependencies!", ->
  lazy "store", -> createStoreOnDb()
  lazy "user", (store) -> createUser(store: store.id)

  it "will load gracefully", (user) ->
    expect(user.store).to.not.be.null()
```

Get much more examples [here](https://github.com/wilkerlucio/barrier/blob/master/test/examples/general_test.coffee)
