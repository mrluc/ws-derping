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

sim = require './sim'

# TODO: CLIENT LIST -- ie list of players WITH sockets.
game = new sim.Game
game.api_setup()
gameApi = game.api
world = game.world

puts = (s)->console.log s
plid = 0

broadcaseGameState = ->


io.sockets.on 'connection', (socket) ->

  # REPLACE
  u = world.players[ socket.id ] = new sim.Player "client#{plid+=1}", socket

  gameApi.setServer( socket )

  console.log io.sockets
  dummy = [1234,1234,1234]
  sendem = dummy
  # huh, sweet, looking at packets specifically ... but gotta capture
  #  from vps first.
  #tcpdump -X -vvi lo0
  derp = setInterval (->
    # we should have one interval that runs along all of the sockets
    #  and does this, ie not one-per.
    pos = world.sim.body.GetPosition()
    console.log pos.x, pos.y
    #socket.send ['gameState',parseInt(pos.x), parseInt(pos.y), 92*92, 92*93]
    send_a = [parseInt(pos.x), parseInt(pos.y), 92*92, 92*93, 92*91]
    send_a.push( 92*91 ) for i in [0..200]
    sendem = if sendem is dummy
      send_a
    else
      dummy
    socket.gameState sendem
  ), 1000

  setInterval (-> socket.balls "Hey man"), 10000
  socket.on 'from_client', (data) -> console.log(data)
  socket.on 'disconnect', ->
    # REPLACE
    delete world.players[socket.id]
    clearInterval derp

server.listen 4001