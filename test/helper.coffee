require("better-stack-traces").install()
path = require("path")

global.requireLib = (modules...) ->
  buildPath = (m) -> path.join(__dirname, "..", "lib", m)

  if modules.length == 1
    require(buildPath(modules[0]))
  else
    for module in modules
      require(buildPath(module))
