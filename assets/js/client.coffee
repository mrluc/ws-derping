## SCRATCH FILE FOR NOW
# Using this to sketch around:
w = window
puts = (args...) -> console.log args...

w.bases = require 'bases'
w._ = require 'underscore'
w.socket = io.connect 'http://localhost:4001'
w.hammer = require './hammer'

# debug view for the physical simulation
# HERP DERP ... reading the box2d code, there's a
#  debugDraw function in there already
# HERP DERP DERPITY.
# okay, let's move towards
w.ourcanvas = document.getElementById "cworld"
w.ctx = ourcanvas.getContext '2d'
[ourwidth,ourheight] = [ourcanvas.width-0, ourcanvas.height-0]

sim = require '../../sim'
w.Box2D = sim.Box2D
_.extend w, Box2D
each_tick = (world)->
  ctx.clearRect(0,0,ourwidth,ourheight)

each_body = ( body )->
  # console.log
  b = body

  fl = body.GetFixtureList()
  return unless fl

  pos = body.GetPosition()
  shape = fl.GetShape()
  shapeType = fl.GetType()
  flipy = ourheight - pos.y

  if shapeType is Box2D.b2Shape.e_circleShape

    radius = 12
    ctx.strokeStyle = "#CCCCCC"
    ctx.fillStyle = "#FF8800"
    ctx.beginPath( )
    ctx.arc(pos.x,flipy,shape.GetRadius(),0,Math.PI*2,true);
    ctx.closePath( )
    ctx.stroke( )
    ctx.fill( )
  else if shapeType is Box2D.b2Shape.e_polygonShape
    vert = shape.GetVertices()
    ctx.beginPath( )

    # Handle the possible rotation of the polygon and draw it
    #b2Math.MulMV(b.m_xf.R,vert[0]);
    tV = b2Math.AddVV(pos, b2Math.MulMV(b.m_xf.R, vert[0]));
    ctx.moveTo(tV.x, ourheight-tV.y)
    for i in [0..vert.length-1]
      v = b2Math.AddVV( pos, b2Math.MulMV(b.m_xf.R, vert[i]) );
      ctx.lineTo( v.x, ourheight - v.y )

    ctx.lineTo( tV.x, ourheight - tV.y )
    ctx.closePath()
    ctx.strokeStyle = "#CCCCCC"
    ctx.fillStyle = "#88FFAA"
    ctx.stroke()
    ctx.fill()

w.game = new sim.Game {a:1}, ourwidth, ourheight, each_tick, each_body
{int_args, int_list} = game.coders

#_.extend game.api_definitions.clientListens,
#  balls: (s)->
#    console.log "CUSTOM" + s
#  gameState: (s)->

game.api_setup()

gameApi = game.api


gameWorld = game.world

gameApi.setClient( socket )

# send data to server
socket.playerAction [5]

console.log gameWorld
