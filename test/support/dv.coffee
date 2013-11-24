W     = require("when")
delay = require("when/delay")

module.exports =
  dv: (value) -> delay(value, Math.round(Math.random() * 10))
