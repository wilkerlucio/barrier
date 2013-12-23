require("better-stack-traces").install()
path  = require("path")
sinon = require("sinon")

BarrierRunner.options.bail = true

lazy "sinon", -> sinon.sandbox.create()
afterEach (sinon) -> sinon.restore()

global.requireLib = (modules...) ->
  buildPath = (m) -> path.join(__dirname, "..", "lib", m)

  if modules.length == 1
    require(buildPath(modules[0]))
  else
    for module in modules
      require(buildPath(module))
