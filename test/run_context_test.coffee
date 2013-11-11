RunContext = requireLib("run_context")

describe "RunContext", ->
  it "requires a test case", ->
    expect(-> new RunContext()).throw "Run context requires a test"

  # it ""
