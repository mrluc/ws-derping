lib = {}
_ = require 'underscore'
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
  constructor: (@w, @h, @each_tick, @each_body) ->
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

    body = @addCircle()

    timeStep = 1.0 / 30.0
    iters = 10

    #for i in [0..60]
    @forever = =>
      @world.Step(1 / 60, 10, 10)
      #@world.Step timeStep, iters
      #position = body.GetPosition()
      #angle = body.GetAngle()
      #console.log "#{i} #{position.x} - #{position.y}"
      #@each_tick position.x, position.y if @each_tick

      @each_tick( @world ) if @each_tick
      if @each_body
        _most( @world.GetBodyList(), 'm_next', @each_body )
    setInterval @forever, 50 # 20fps
    # TODO: class this for node/browser
    #z = setInterval(eachStep, timeStep);

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

class lib.Player extends Backbone.Model
  constructor: (@name)->
  some_action: (intAmount )=>
    console.log "OMG CALLED ----- #{[ intAmount ]}"

class lib.EventUnpacker

class lib.WorldEventParser

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

    # Even if players are entities like other game entities,
    #  and there's a base class/mixin under there,
    #
    # Players
    #   have_a physical_entity # phys attrs ...
    #   have_a user_state      # pending player actions,...
    #     PLUS: lots of other game state
    #
    # World
    #   has_many fixed_geometries
    #
    # COMM:
    #   client sends:
    #     user actions
    #      (move, rotate, fire/jump/ etc) optimized
    #      broadcast messages, enter/leave not optim.
    #   server sends:
    #     world geom
    #     entity attributes

    # players will be attached via userData, and here we may
    #  hook up their actions, ie - user has "frame_actions" of
    #  ops to perform in order.
    # But we provide a mapping class between the UserState obj
    #  and the PhysicalEntity.
    #
    # AHA- and they get updated separately, too.
    #
    # The client sends updates to UserState.
    #  (Probably via some mechanism like queueing actions)
    #
    # On both server and client, those actions can be consumed and
    #  allowed to take effect - so the logic that processes them should
    #  be shared:
    #
    # USER JUMPS
    #
    #  User adds to
    #
    #  And it should go ahead and update itself, too. It'll get overwritten
    #  by the authority on the server, that's fine.
    #
    # The server sends updates to PhysicalEntity(ies)
    #
    #    - it could set up(pseudocode)
    #
    #   @userState.on 'change:frame_actions', @dispatchNew (changed)->
    #     for {action, args} in changed
    #       @["do_#{action}"], args
    #
    # etc

#lib.

module.exports = exports = lib
