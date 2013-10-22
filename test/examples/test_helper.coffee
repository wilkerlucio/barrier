Q = require("q")

module.exports =
  dv: (value) -> Q(value).delay(Math.round(Math.random() * 100))