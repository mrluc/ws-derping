lg = puts = (s...)->console.log s...

connect = require 'connect'
express = require 'express'
app = express()
server = require('http').createServer(app)
app.use connect.compress()
io = require('socket.io').listen server,
  "browser client gzip":yes
  "browser client minification":yes

env = 'development'
debug = yes

lg 'Configuring css - node-sass middleware'
sass =
  src: "#{__dirname}/assets/css"
  dest: "#{__dirname}/public"
  debug: debug
app.use require('node-sass').middleware sass

lg 'Configure views - static public; view engine'
app.use express.static "#{__dirname}/public"
app.set 'view engine', 'jade'
app.engine 'jade', (require 'consolidate').jade

lg 'Configure js - browserify with entry of client.coffee'
browserify = require 'browserify'
bundle = browserify
  entry: "#{__dirname}/assets/js/client.coffee"
  debug: debug
  mount: "/bundle.js"
  watch: yes
app.use bundle

lg 'Configure routes - one route, one view'
app.get '/', (req, res) -> res.render 'index'

comm = require './comm'
cnv = comm.Conversions
sim = require './sim'
world = new sim.World


#callUnpacker = (argConsumers..., fnToCallWithArgs = puts)->
#  (s)->
#    puts "A string -- #{s} -- that is #{s.length} chars long"
#    args=[]
#    for argFn in argConsumers
#      [val, rest] = argFn s
#      puts "Consumed #{val}, rest: #{rest}"
#      s = rest
#      args.push val
#    puts "Now going to call with args: #{args}"
#    fnToCallWithArgs( args... )

#utfIntConsumer = (bytes)->
#  (s)->
#    chars = s.slice( 0, bytes )
#    puts "string: #{s}.going to convert #{chars},
#      which is #{chars.length} long"
#    val = cnv.to_i chars
#    rest = s.slice( bytes, s.length )
#    [ val, rest ]

#unpacker = cnv.PackedCalls.unpacker utfIntConsumer(3), (i)->
#  console.log "NO WAY. AWESOME ---> #{i}"

puts cnv.to_i cnv.to_s 123545
#puts utfIntConsumer(3) cnv.int2utf 123545

puts "TESTING: "
comm.test()
process.exit()

# so at least fn sig, we want to get down to 1 char.
#  surely.
# then after that, it's a mapping fn.
emap = new comm.TinySocketApi
  serverListens:
    consumePlayerActions: (s)->

  clientListens:
    # player movement events are the big thing
    #  to broadcast - or at least the actual new
    #  positions/directions w/the action taken.
    # also objects that have recently collided w/players
    gameState: (s)->
      console.log "gS: #{s}"

#throw emap.clientApi
emap.clientApi.named.gameState('blah')

# For the heck of it: let's start binding to world.player
# so how would this work? I'd say: users

puts = (s)->console.log s
io.sockets.on 'pa', (data)-> throw "OOOOOOONOOOOOOZ"
io.sockets.on 'connection', (socket) ->
  #console.log socket
  # these sorts of fns would likely only be called on a fixed
  #  schedule, not in response to user action
  # ack = -> socket.emit 'ack', 1
  # TODO: separate out the entity map from the each-tick
  #  updates. Ie, number of players and their ids, that should
  #  come down the wire very rarely, and can be requested
  #  if a client gets out of sync.
  # BENEFIT: entity position, other updates can be tiny!
  sayGameState = ->
    socket.emit 'g', "sflmsdflkmsdfl;kmasdflk;masdf"
  setInterval sayGameState, 2000

  # TODO: all object keys should be tiny as well.
  #
  u = world.players[ socket.id ] = {
    userActions: [],
    state: {}
  }

  socket.on 'pa', (data)->
    puts "Yaaaargh I consume player action, #{data}!"

  socket.on 'from_client', (data) -> console.log(data)
  socket.on 'disconnect', ->
    delete world.players[socket.id]

server.listen 4001