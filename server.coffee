lg = puts = (s...)->console.log s...

# ------- CONFIG -------
#
connect = require 'connect'
express = require 'express'
app = express()
server = require('http').createServer(app)
app.use connect.compress()
io = require('socket.io').listen server,
  "browser client gzip": yes
  "browser client minification": yes

env = 'development'
debug = yes

lg 'Configuring css - node-sass middleware'
sass =
  src: "#{  __dirname }/assets/css"
  dest: "#{ __dirname }/public"
  debug: debug
app.use require('node-sass').middleware sass

lg 'Configure views - static public; view engine'
app.use express.static "#{ __dirname }/public"
app.set 'view engine', 'jade'
app.engine 'jade', (require 'consolidate').jade

lg 'Configure js - browserify, entry:client.coffee'
browserify = require 'browserify'
bundle = browserify
  entry: "#{__dirname}/assets/js/client.coffee"
  debug: debug
  mount: "/bundle.js"
  watch: yes
app.use bundle

lg 'Configure routes - one route, one view'
app.get '/', (req, res) -> res.render 'index'

# ------- GAME ---------
#
comm = require './comm'
sim = require './sim'
comm.test()

# TODO: CLIENT LIST -- ie list of players WITH sockets.
game = new sim.Game
game.api_setup()
gameApi = game.api
world = game.world

puts = (s)->console.log s
io.sockets.on 'connection', (socket) ->

  # REPLACE
  u = world.players[ socket.id ] = { userActions: [], state: {} }

  gameApi.setServer( socket )


  setInterval (->
    pos = world.sim.body.GetPosition()
    console.log pos.x, pos.y
    socket.gameState [parseInt(pos.x), parseInt(pos.y)]
  ), 1000

  setInterval (-> socket.balls "Hey man"), 10000
  socket.on 'from_client', (data) -> console.log(data)
  socket.on 'disconnect', ->
    # REPLACE
    delete world.players[socket.id]

server.listen 4001