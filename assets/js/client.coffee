## SCRATCH FILE FOR NOW
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

# our tinySocketApi
w.gameApi = comm.gameApi
gameApi.setClient( socket )

# send data to server
socket.playerAction [5]

# TODO: Okay, this is a DEBUG MODE just for
#  the physical sim portion. These eachticks
#  should be for the game world, not physsimworld
#
w.ourcanvas = document.getElementById "cworld"
w.ctx = ourcanvas.getContext '2d'
[ourwidth,ourheight] = [ourcanvas.width-0, ourcanvas.height-0]

sim = require '../../sim'
w.Box2D = sim.Box2D

each_tick = (world)->
  ctx.clearRect(0,0,ourwidth,ourheight)

each_body = ( body )->
  # console.log
  b = body
  pos = body.GetPosition()
  fl = body.GetFixtureList()
  if fl
    shape = fl.GetShape()
    shapeType = fl.GetType()
    flipy = ourheight - pos.y

    if shapeType is Box2D.b2Shape.e_circleShape

      # draw circle
      #
      radius = 12
      ctx.strokeStyle = "#CCCCCC";
      ctx.fillStyle = "#FF8800";
      ctx.beginPath();
      ctx.arc(pos.x,flipy,shape.GetRadius(),0,Math.PI*2,true);
      ctx.closePath();
      ctx.stroke();
      ctx.fill();
    else if shapeType is b2Shape.e_polygonShape
      vert = shape.GetVertices();
      ctx.beginPath();

      # Handle the possible rotation of the polygon and draw it
      b2Math.MulMV(b.m_xf.R,vert[0]);

      tV = b2Math.AddVV(pos, b2Math.MulMV(b.m_xf.R, vert[0]));
      ctx.moveTo(tV.x, ourheight-tV.y);
      for i in [0..vert.length-1]
        v = b2Math.AddVV(pos, b2Math.MulMV(b.m_xf.R, vert[i]));
        ctx.lineTo(v.x, ourheight - v.y);

      ctx.lineTo(tV.x, ourheight - tV.y);
      ctx.closePath();
      ctx.strokeStyle = "#CCCCCC";
      ctx.fillStyle = "#88FFAA";
      ctx.stroke();
      ctx.fill();

w.gameWorld = new sim.World ourwidth, ourheight, each_tick, each_body

console.log gameWorld



# JANKY OLD DEMO FOR LEARNING
# this: just for the janky old demo that loads later in the
#  page. We need it around to take apart things, like the
#  vertex api for shapes, etc.
_.extend window, Box2D

# recurring would be prettier, but it's a circular
#  linked list, so meh
_most = (original, key, fn) ->
  [cur, next] = [original, no]
  while cur
    fn cur
    next = cur[key]
    break if not next or next is original # could still recur
    cur = next

each_sim_tick = ->
  #bodies = world.GetBodyList()
  #_most bodies, 'm_next', (o)->
  #  console.log o

nows = Date.now()
keepGoing = ->
  (Date.now() - nows) < 1000
  yes

ticks=0
w.update2 = ->
  ticks += 1
  # very primitive ... we want it to execute regardless of draw
  # speed.
  world.Step(1 / 60, 10, 10)
  context.clearRect(0,0,canvaswidth,canvasheight);
  world.ClearForces();

  # these fns all exist in the old demo
  processObjects()

  if keepGoing()
    each_sim_tick()
    M = Math.random();
    if (M < .01)
      # addImageCircle();
    else if (M < .04)
      # addTriangle()
    else if (M > .99)
      addCircle()
