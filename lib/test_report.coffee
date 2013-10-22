module.exports = class TestReport
  constructor: (@test, @err = null) ->

  isSuccess: -> !@err
  isFailed: -> !@isSuccess()
