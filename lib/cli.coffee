pkg = require("../package.json")
program = require("commander")

program
  .version(pkg.version)
  .usage("[options] <file ...>")
  .option("-v, --verbose")
  .option("-R, --reporter <name>", "specify the reporter to use")
  .option("--reporters", "display available reporters")

program.on "reporters", ->
  console.log()
  console.log "    dot - dot matrix"
  console.log "    doc - html documentation"
  console.log "    spec - hierarchical spec list"
  console.log "    json - single json object"
  console.log "    progress - progress bar"
  console.log "    list - spec-style listing"
  console.log "    tap - test-anything-protocol"
  console.log "    landing - unicode landing strip"
  console.log "    xunit - xunit reporter"
  console.log "    html-cov - HTML test coverage"
  console.log "    json-cov - JSON test coverage"
  console.log "    min - minimal reporter (great with --watch)"
  console.log "    json-stream - newline delimited json events"
  console.log "    markdown - markdown documentation (github flavour)"
  console.log "    nyan - nyan cat!"
  console.log()
  process.exit()

program.parse process.argv

Suite  = require("../lib/suite.coffee")
Runner = require("../lib/runner.coffee")
Path   = require("path")
_      = require("lodash")

files = _.map program.args, (path) -> Path.resolve(path)

suite = global.BarrierSuite = new Suite()
runner = global.BarrierRunner = new Runner(suite)
runner.reporter(program.reporter or "dot")

suite.withDSL -> require(file) for file in files

require("./suite_processors/only.coffee")(suite.children)

runner.run().then(
  -> process.exit(runner.stats.failures)
  (err) -> throw err
)
