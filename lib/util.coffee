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

  qSequence: (sequence, acc = null) ->
    sequence ||= []
    return Q(acc) unless sequence.length

    promise = Q.promised(sequence.shift())(acc)
    promise.then (res) -> util.qSequence(sequence, res)

  flag: (obj, key, value) ->
    return null unless obj
    flags = obj[util.flag.key] || (obj[util.flag.key] = {})

    return flags if arguments.length == 1
    return flags[key] if arguments.length == 2
    flags[key] = value; obj

  parentLookup: (obj, context, key) ->
    return unless obj and context
    ctx = obj[context] || (obj[context] = {})

    if key?
      ctx[key] || util.parentLookup(obj.parent, context, key)
    else
      return _.extend(util.parentLookup(obj.parent, context), ctx) if obj.parent
      _.clone(ctx)

  ancestorChain: (obj) ->
    if obj then [obj].concat(util.ancestorChain(obj.parent)) else []

util.flag.key = "__flags"
