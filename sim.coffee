lib = {}
_ = require 'underscore'
ext = require './extensions'
comm = require './comm'
{PackedCalls, TinySocketApi, Coders, Conversion} = comm

Backbone = require 'backbone'

lib.Box2D = b = Box2D = require 'box2dnode'

_most = (original, key, fn) ->
  [cur, next] = [original, no]
  while cur
    fn cur
    next = cur[key]
    break if not next or next is original # could still recur
    cur = next

class lib.PhysicalSimulation
  constructor: (@w=300, @h=150, @each_tick, @each_body) ->
    @gravity = new b.b2Vec2(0, -10)
    @world = new b.b2World @gravity, doSleep = no

    fixDef = new b.b2FixtureDef
    _.extend fixDef,
      density: 0.5
      friction: 0.4
      restitution: 0.2
      shape: new b.b2PolygonShape
    bodyDef = new b.b2BodyDef
    _.extend bodyDef,
      type: b.b2Body.b2_staticBody

    # hardcoding assuming 300px wide, 150 tall.
    # look in box2d apis to 'get' these
    fixDef.shape.SetAsBox @h, 2

    bodyDef.position.Set @h, 0
    @world.CreateBody(bodyDef).CreateFixture(fixDef)
    bodyDef.position.Set(@w/2, @h - 2);
    @world.CreateBody(bodyDef).CreateFixture(fixDef);

    @body = @addCircle()

    timeStep = 1.0 / 30.0
    iters = 10


    @forever = =>
      @world.Step(1 / 60, 10, 10)
      @each_tick( @world ) if @each_tick
      if @each_body
        _most( @world.GetBodyList(), 'm_next', @each_body )
    setInterval @forever, 50 # 20fps

  addCircle: =>
    bodyDef = new b.b2BodyDef;
    fixDef = new b.b2FixtureDef;
    fixDef.density = .5;
    fixDef.friction = 0.1;
    fixDef.restitution = 0.2;

    bodyDef = new b.b2BodyDef;
    bodyDef.type = b.b2Body.b2_dynamicBody;
    scale = Math.random() * 40;

    fixDef.shape = new b.b2CircleShape(
      scale * Math.random()
    );
    bodyDef.position.x = (@w - scale*2)*Math.random() + scale * 2;
    bodyDef.position.y = @h - (scale * Math.random() + scale * 2);
    b = @world.CreateBody(bodyDef)
    f = b.CreateFixture(fixDef);

    console.log "-----"
    console.log b
    b

class lib.Player  # extends Backbone.Model
  constructor: (@name, @socket)->


class lib.EventUnpacker
class lib.World
  # The each_tick should be for GAME objects, not just
  #  physical bodies ...
  # BUT we will need a debug mode at any rate for the phys
  #  stuff, so do that.
  #
  # TODO: just pass through all args to physsim
  constructor: (args...)->
    @time = Date.now()
    @sim = new lib.PhysicalSimulation args...
    @player = new lib.Player
    @players = {} #by id, probably same/derived ws id as well

# (I'm so sorry)
class CompilingApiCall
  constructor: (@maker, @args...)->
    return unless @args
    unless @isready()
      if @args? and not @isdumb()
        @args.push (val...)-> console.log ["UNBOUND:", val]

  isdumb: =>
    @maker and @args.length is 0
  isready: =>
    _.isFunction( _.last( @args )) or @args.length is 0
  fn: (fn)=>
    if @isdumb()
      @maker = fn
    else if @isready()
      @args[ @args.length-1 ] = fn
    else
      @args.push fn
  compile: =>
    if @isdumb()
      result = @maker
    else
      result = @maker @args...
    result
  dbg: =>
    console.log @

class lib.Game
  # hold World, TinySocketApi
  {int_args, int_list} = Coders
  coders: Coders

  # this is what we'll be overriding on clie/serv, I guess via the
  #  methods of CompilingApiCall if we decide it can stick around
  api_definitions:
    serverListens:
      playerAction:
        new CompilingApiCall int_args, 2, (val...)->
          console.log "PLAYER ACTION ________ OMG OMG #{ val }"
    clientListens:
      gameState:
        new CompilingApiCall int_list, 2, (s...)->
          console.log "GAME STATE _____ OMG OMG OMG #{ s }"

      balls2:
        new CompilingApiCall (s)->
          console.log s
      balls:
        new CompilingApiCall (s)->
          console.log s
      list:
        new CompilingApiCall int_list, 5, (val)->
          console.log "WHOA LISTY LISTISH LISTERINE!!!!"
          console.log val

  constructor: (cbs, args...)->
    # client/server should pass in listeners that they
    #  want to override.
    unbound = (val...)-> console.log ["UNBOUND:", val]

    @world = new lib.World args...

  api_setup: =>
    console.log "------- --------"
    for k, hash of @api_definitions
      for fname, cfn of hash
        console.log "fname: #{fname}"
        #console.log cfn
        #console.log
        #console.log ["compiled:", (comp = cfn.compile())]
        comp = cfn.compile()
        hash[ fname ] = comp

    @api = new TinySocketApi @api_definitions



module.exports = exports = lib
