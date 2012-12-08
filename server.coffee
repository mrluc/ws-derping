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
pack = comm.PackedCalls
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

# okay -- we need to simulate a
unpack = pack.unpacker pack.s2i(3), (args...)->
  lg "NO WAY. AWESOME ARGS ---> "
  lg JSON.stringify(arg) for arg in args

lg unpack cnv.to_s 12345

comm.test()

# TODO: CLIENT LIST -- ie list of players, which HAVE sockets.

gameApi = comm.gameApi

puts = (s)->console.log s
io.sockets.on 'connection', (socket) ->

  #sayGameState = ->
  #  socket.emit 'g', "sflmsdflkmsdfl;kmasdflk;masdf"
  #setInterval sayGameState, 2000

  # TODO: all object keys should be tiny as well.
  #
  u = world.players[ socket.id ] = {
    userActions: [],
    state: {}
  }

  #gameApi.serverListen( socket )
  gameApi.setServer( socket )

  socket.playerAction "THING" for i in [0..12]

  socket.on 'pa', (data)->
    puts "Yaaaargh I consume player action, #{data}!"

  socket.on 'from_client', (data) -> console.log(data)
  socket.on 'disconnect', ->
    delete world.players[socket.id]

server.listen 4001