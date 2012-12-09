## SCRATCH FILE FOR NOW
#
# Using this to sketch around:

w = window
puts = (args...) -> console.log args...

w.bases = require 'bases'
w._ = _ = require 'underscore'
w.Backbone = require 'backbone'
w.socket = io.connect 'http://localhost:4001'
w.hammer = require './hammer'

window.comm = require '../../comm'
cnv = comm.Conversions
_.extend window, cnv

everyNs = (seconds, fn)-> _.debounce fn, seconds*1000
every5s = (fn)-> everyNs 5, fn
log5s = every5s (s)-> console.log s
log5s = _.debounce ((s)-> console.log s), 5000

# in addition to the ones that gameApi.setClient sets up for us
#  TODO remove, verbose.
socket.on 'message', (s)->console.log "----->>>>>>>>> #{ s }"



# This part is actually important
w.gameApi = comm.gameApi
gameApi.setClient socket
socket.playerAction [5] #a bit stilted
# that's it (for now ...)

# hah. recurring would be prettier, but it's a circular
#  linked list, so meh
_most = (original, key, fn) ->
  [cur, next] = [original, no]
  while cur
    fn cur
    next = cur[key]
    break if not next or next is original # could still recur
    cur = next

sim = require '../../sim'
w.Box2D = sim.Box2D

# this: just for the janky old demo that loads later in the
#  page. We need it around to take apart things, like the
#  vertex api for shapes, etc.
_.extend w, sim.Box2D


each_sim_tick = ->
  #bodies = world.GetBodyList()
  #thing = Math.random()
  #_most bodies, 'm_next', (o)->
  #  console.log "found one #{thing}"
  #  console.log o

nows = Date.now()
keepGoing = ->
  (Date.now() - nows) < 1000

ticks=0
w.update2 = ->
  ticks += 1
  # very primitive ... we want it to execute regardless of draw
  # speed.
  world.Step(1 / 60, 10, 10);
  context.clearRect(0,0,canvaswidth,canvasheight);
  world.ClearForces();

  processObjects()
  if keepGoing()
    each_sim_tick()

  if keepGoing()
    M = Math.random();
    if (M < .01)
      # addImageCircle();

    else if (M < .04)
      # addTriangle()

    else if (M > .99)
      addCircle()
