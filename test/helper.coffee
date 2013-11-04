path = require("path")
sinon = require("sinon")

global.requireLib = (modules...) ->
  buildPath = (m) -> path.join(__dirname, "..", "lib", m)

  if modules.length == 1
    require(buildPath(modules[0]))
  else
    for module in modules
      require(buildPath(module))

# sinon sandbox
lazy "sinon", -> sinon.sandbox.create()
afterEach (sinon) -> sinon.restore()
