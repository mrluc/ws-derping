lg = (s...)->console.log s...

connect = require 'connect'
uglify = require 'uglify-js'
express = require 'express'
app = express()
server = require('http').createServer(app)
app.use connect.compress()
io = require('socket.io').listen server,
  "browser client gzip":yes
  "browser client minification":yes

env = 'development'
debug = yes

lg 'Configuring sass'
#app.use require('connect-assets')() #using browserify + node-sass atm
sass =
  src: "#{__dirname}/assets/css"
  dest: "#{__dirname}/public"
  debug: debug
app.use require('node-sass').middleware sass

lg 'Configure Express - public dir, view engine'
app.use express.static "#{__dirname}/public"
app.set 'view engine', 'jade'
app.engine 'jade', (require 'consolidate').jade

# stick browserify here:

browserify = require 'browserify'
bundle = browserify
  entry: "#{__dirname}/assets/js/app.coffee"
  debug: debug
  mount: "/bundle.js"
  watch: yes

app.use bundle


# SPA-Style - one route, one view, static/cacheable
app.get '/', (req, res) -> res.render 'index'

comm = require './comm'
sim = require './sim'
world = new sim.World

# NEEDED:
# 1. Functions that return parsed vals (ints, strs
#    mostly).
# 2. The fn that knits them together into a call:
#    something like:
#
#  unpackCall player.do_something,
#    s2bImpulseVec(2,2),  # makes vector w/2byte precis
#
#  unpackCall would give us the function that consumes
#  those portions of the string - so the return of the
#  conversion fns needs to be multiple: [ val, rest ].

# no chance. But base64 yes ... jesus that's 1/4th the max
# efficiency, and we were using base 36 ...
#
base64 = require './base64'

utf8ToInt = (bytePrecision)->
  (s)->
    chars = s.slice 0, bytePrecision
    rest = s.slice bytePrecision, s.length
    bstr = ""
    bstr.push(chars.charCodeAt i ) for i in [0..chars.length-1]
    console.log bstr

  # huh ... if it really does send/specify utf-8, then we ought
  # to be safe doing this. But maybe roll our own - 255 to base 2
  #   yeah, man, people send forms w/special chars etc. WS/transport
  #   is UTF-8, so it ought to be good, as utf doesn't have
  #   non-printing ... guess we'll find out if that's not true...
  # huh ... duh ... yes, that IS how to do it, concat each 255 to
  #  the next, just figure out order of ops.
  #    1. grab charcode from char
  #    2. turn it into binary string
  #    3. turn it into int
  # and otherwise,
  #    1. turn int into binary string
  #    2. grab 8-char chunks from the left - right-pad final w/0s
  #    3. turn each into a charcode appended to string.
intToUtf8 = ()->




s2int = (maxN)->
  (s)->
    numChars = Math.ceil( maxN / 36 )
    val = parseInt s.slice( 0, numChars ), 36
    rest = s.slice( numChars, s.length)
    [ val, rest ]

unpackCall = (argConsumers..., fnToCallWithArgs)->

  (s)->
    args=[]
    for argFn in argConsumers
      [val, rest] = argFn s
      s = rest
      args.push val

    fnToCallWithArgs( args... )

# boy - do the strings we send survive with all 255 char codes?
#  hmmm.
unpacker = unpackCall s2int(1200), (i)-> console.log "NO WAY. AWESOME ---> #{i}"

unpacker "af"
# so at least fn sig, we want to get down to 1 char.
#  surely.
# then after that, it's a mapping fn.
emap = new comm.TinySocketApi
  serverListens:
    consumePlayerActions: (s)->

  clientListens:
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
    socket.emit 'gameState', "sflmsdflkmsdfl;kmasdflk;masdf"
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