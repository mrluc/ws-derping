## SCRATCH FILE FOR NOW
# Currently sketching around:
#  - box2d
#  - hammer
#
w = window
puts = (args...) -> console.log args...

w._ = require 'underscore'
w.socket = io.connect 'http://localhost:4001'
w.Hammer = require './hammer'
sim = require '../../sim'

w.Box2D = sim.Box2D
_.extend w, Box2D
w.ourcanvas = document.getElementById "cworld"
w.ctx = ourcanvas.getContext '2d'

# currently passing along to PhySim
[ourwidth,ourheight] = [ourcanvas.width-0, ourcanvas.height-0]

# ---- debug draw
# HERP DERP ... reading the box2d code, there's a
#  debugDraw function in there already! gah.
# let's move towards the dom renderer -- that
#  seems really fun.

each_tick = (world)->
  ctx.clearRect(0,0,ourwidth,ourheight)
each_body = ( body )->
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
# ----- end debug draw

w.game = new sim.Game {a:1}, ourwidth, ourheight, each_tick, each_body
{int_args, int_list} = game.coders
{gameState, balls, list} = game.api_definitions.clientListens

# OMGEEZY, api r xtenzible on clinet
gameState.fn (s)-> # hesh!
balls.fn (s)->
  console.log "CUSTOM EXTENSIBLE OMGEEZY: #{ s }"

game.api_setup()
gameApi = game.api
gameWorld = game.world
gameApi.setClient( socket )

# send data to server
socket.playerAction [5]

class Draggy extends Hammer
  # okay - TODO - this guy should become
  #  home for the touch events we recognize,
  #  we need a kb events handler too, and
  #  then an InteractionWatcher
  #  that maps those to player/sim
  #  actions.
  ondragstart: (ev)=>
    {@x,@y} = ev.originalEvent
    puts [@x,@y]
  ondragend: (ev)=>
    {x,y} = ev.originalEvent
    puts [x,y]
    @dragline {x: @x,y: @y}, {x: x,y: y} if @dragline

hammer = new Draggy document.getElementById( "draggy" )
hammer.dragline = (o,n)-> #old, new
  [dx, dy] = [n.x-o.x, n.y-o.y]
  m = 1 # multiplier
  bv = new b2Vec2( -dx * m, dy * m )

  body = gameWorld.sim.body
  puts bv

  # this is what we want now:
  body.SetLinearVelocity bv
  # this would be good for some kinds of things:
  #body.ApplyForce bv, body.GetWorldCenter()



# sweet.
  # so this is really where we'd be triggering
  #  a player action - client interaction event
  #  gets turned into a format that player actions
  #  understand. The player actions (which probably
  #  massage the vec to be within allowable ranges)
  #  would trigger the actual SetLinearVelocity
  #  call locally. Probably no need to abstract
  #  up that stuff, ie player can_haz_a body; it's
  #  enough that player.fling(direction) would
  #  work reliably.
  #
  # In fact player probably also can_haz_a socket,
  #  just that on client only one player will.
  #

  # of course we could always just bind these
  #  things via events -
  #  ie sockets, physicalworld
  #  could be outside and set up listeners on the model.
  # i do like that idea a bit ... so be aware when
  #  we start using the player model more.
  #

  #
  # For server: client listening for player
  #  actions and sending them to be performed on
  #  server can be done via backbone events.
  #
  # Ie just listen for the player action events
  #  and proxy them/their args up to server.
  #  From there everything should 'just work',
  #  with the next tricky task back on the client,
  #  reconciling the server's sim state gracefully
  #
  # In fact for what we set up locally, for
  #  the ModelWorld, which is what the rendering
  #  will be based on, I loooove
  #  backbone. It's just that for the purposes of these
  #  experimentes I don't want to rely on
  #  its comm portions; trying to learn new stuff.
  #

  # Now ...