[
  browserify
  watch
] = (require s for s in ['browserify', 'watch'])

# hmm, now that we're handling both sass
# and coffeescript with middlewares ... maybe this file becomes
# a middleware-config block.
#   The 'watch' stuff is cool and useful for the general case, hold onto it.


class AssetManager
  constructor: (@types)->

  build_js: ()=>
    # we'll want to do browserify here
    browserify
  build_css: ()=> #passthrough - we're using node-sass atm.

  build: ()=>



  watch: (asset_type = 'js', onChange)=>

    # call this to start watching
    onChange ?= (args...)->
      console.log "Foo:"
      console.log args
    evts =
      created: foo
      changed: foo
      removed: foo
    watch.createMonitor @jsDir, (monitor)->
      monitor.on(evt, fn) for evt, fn of evts

      #monitor.on "created", foo #(f, stat)->
      #  # Handle file changes
      #monitor.on "changed", foo #(f, curr, prev)->
      #  # Handle new file
      #monitor.on "removed", foo #(f, stat)->


module.exports = (fn)->
  new AssetManager(fn())