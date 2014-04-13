require('../helper.coffee')

processOnly = require("../../lib/suite_processors/only.coffee")

describe "Suite Processor - Only", ->
  describe "given a test has the only flag", ->
    flagOnly = -> __flags: {only: true}
    flagSkip = -> __flags: {skip: true}

    it "skips other tests", ->
      suite = [flagOnly(), {}]
      processOnly(suite)
      expect(suite).eql [flagOnly(), flagSkip()]

    it "works on deep nesting", ->
      deepOnly = flagOnly()
      deepOnly.children = [{}, {}]

      suite = [{}, deepOnly, flagOnly()]
      processOnly(suite)
      expect(suite).eql [
        flagSkip(),
        deepOnly,
        flagOnly()
      ]
