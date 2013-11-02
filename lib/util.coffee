_ = require("underscore")
Q = require("q")

module.exports = util =
  reversibleChange: (obj, extension, block) ->
    backup = {}

    for key, value of extension || {}
      backup[key] = obj[key]
      obj[key] = value

    restore = ->
      for key, value of backup
        if value == undefined
          delete obj[key]
        else
          obj[key] = value

      null

    if block?
      Q(block()).then -> restore()
    else
      restore

  qSequence: (sequence, options = {}) ->
    sequence ?= []

    {interceptor, prepare, arg} = options = _.extend
      prepare: _.identity
      interceptor: _.identity
      arg: null
    , options


    Q(interceptor(arg)).then (res) ->
      return res if sequence.length == 0

      fn = prepare sequence.shift()

      next = if _.isFunction(fn) then Q.promised(fn)(res) else fn
      next.then (prep) -> util.qSequence(sequence, _.extend(options, arg: prep))

  flag: (obj, key, value) ->
    return null unless obj
    flags = obj.__flags || (obj.__flags = {})

    return flags if arguments.length == 1
    return flags[key] if arguments.length == 2
    flags[key] = value; obj
