Q = require("q")

module.exports =
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
