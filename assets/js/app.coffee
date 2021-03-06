## SCRATCH FILE FOR NOW
#
# Using this to sketch around:

w = window
puts = (args...) -> console.log args...

w._ = _ = require 'underscore'
w.Backbone = require 'backbone'
w.socket = io.connect 'http://localhost:4001'
w.hammer = require './hammer'

comm = require '../../comm'
cnv = comm.Conversions
_.extend window, cnv   # ERROR CASE: puts utf2int(int2utf(12545))

everyNs = (seconds, fn)-> _.debounce fn, seconds*1000
every5s = (fn)-> everyNs 5, fn
log5s = every5s (s)-> console.log s
log5s = _.debounce ((s)-> console.log s), 5000

socket.on 'gameState', (data)->
  log5s data
  socket.emit 'pa', my:'data'

# TODO
#  okay, we have a running simulation. Congrats.



# hah. recurring would be prettier, but it's a circular
#  linked list, so meh
_most = (original, key, fn) ->
  [cur, next] = [original, no]
  while cur
    fn cur #
    next = cur[key]
    break if not next or next is original # could still recur
    cur = next

w.base64 = require '../../base64'
sim = require '../../sim'
w.Box2D = sim.Box2D
_.extend w, Box2D...

# this: just for the janky old demo that loads later in the
#  page. We need it around to take apart things, like the
#  vertex api for shapes, etc.
_.extend w, sim.Box2D
each_sim_tick = ->
  bodies = world.GetBodyList()
  thing = Math.random()
  _most bodies, 'm_next', (o)->
    console.log "found one #{thing}"
    console.log o

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
