
_ = require 'underscore'
ext = require('./extensions')
lg = puts = (s...)->console.log s...
# awwwwww yeah
#
# TODO: write some more dream code -- we've got
#  actual conversion code, so now it's time
#  to go back to TinySocketApi and figure out,
#  what's our "dream code"; ideally, how should
#  it work?
#
# Hmmm. Maybe start hooking up the reporting of
#  the position of a body in sim, simplest thing poss,
#  maybe not even using and then
#  hook up some 'player actions', and the process
#  of doing that will guide dev.

Module = ext.Module

class Alphabet extends Module
  @include require 'bases'
  constructor: (@byPosition)->
    @base = @byPosition.length
    @byLetter = {}
    for s, i in @byPosition.split ""
      @byLetter[s] = i
    @padChar = @to_s 0
  pad: (s, len)=>
    s = @padChar + s for i in [1..(len-s.length)]
    s
  to_s: (i,padNumChars=no)=>
    s = @toAlphabet i, @byPosition
    if padNumChars then @pad(s,padNumChars) else s

  to_i: (str,padTo=no)=>
    digits = str.split ""
    [len, num] = [digits.length, 0]
    for s, i in digits
      int = @byLetter[s]
      multi = Math.pow @base, (len - i - 1)
      int = int * multi if multi > 0
      num += int
    num

class Conversions extends Module
  @include require 'bases'
  @e92 = new Alphabet [
    "~`!1@2#3$4%5^6&7*8(9)0"
    " _-+={[}]|:;<,>.?/"
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  ].join('')
  {@to_s, @to_i} = @e92

class CompressedKeys extends Module
  @include _
  constructor: (@named)->
    @tiny = {}
    sorted = @sortBy ([k,v] for k,v of @named),
      ([key,cb])-> key
    @tiny[i.toString(36)] = cb for [key,cb], i in sorted

  findParallelKey: (key, first, second)->
    if val = first[key]
      return key2 for key2, val2 of second when val is val2
      no
    else no

  nameForTiny: (tiny)=> @findParallelKey tiny, @tiny, @named
  tinyForName: (name)=> @findParallelKey name, @named, @tiny


class PackedCalls extends Module

  #HEY. With approp. argsConsumers,
  # couldn't this work for encoding as well? Seems
  # general enough ...
  @unpacker = (argConsumers..., fnToCallWithArgs = puts)->

    (s)->
      args=[]
      for argFn in argConsumers
        [val, rest] = argFn s
        s = rest
        args.push val
      fnToCallWithArgs( args..., rest )
  #@packer = (args)
# SO NOW: SENDING.
#  Dream code that works on client and server is sort
#  of difficult to envisage, plays tricks on ya ...
#
class TinySocketApi extends Module
  @include _
  constructor: ({@serverListens, @clientListens})->
    @serverApi = new CompressedKeys @serverListens
    @clientApi = new CompressedKeys @clientListens

  setEmitters: (sock, api)->
    for fname, cb of api.named
      evt = api.tiny.findParallelKey fname, api.named, api.tiny
      sock[ fname ] = (args...)->
        sock.emit( evt )

  setListeners: (sock, api)->
    sock.on evt, cb for evt, cb of api.tiny

  serverListen: (sock)=>
    @setListeners sock, @serverApi

  clientListen: (sock)=>
    @setListeners sock, @clientApi

# SAMPLE -- whatever the api ends up being,
# at least the definition aspect should be shared
# client/server.
#
#   serverListens:
#     playerAction: unpacker argsfn, (s)-> fn to feed extracted..
#
# Now to SEND data over this from the client, client wants
#
#  socket.send "`","adflmdsaflmsdaf"
# via gameApi.client.playerAction("Walked forward")
#
# serverListens:
#   playerAction:
#     rcv:
#     send:
#
#   YAAAAAAAAAAAAAAAARGH still no firm idea of how
#   this should all work.
#
# Maybe on setup, I say:
#
#  gameApi = gameApi.setServer()
#
# That hooks up the serverListens.rcv, and the
# clientListens.sends.
#
# ??? Seems legit, we still need @packer in PackedCalls
#
exports.gameApi = new TinySocketApi
  serverListens:
    playerAction: (s)->
      console.log "PLAYER ACTION ________ OMG OMG #{ s }"
  clientListens:
    gameState: (s)->
      console.log "GAME STATE _____ OMG OMG OMG #{ s }"

exports.PackedCalls = PackedCalls
exports.TinySocketApi = TinySocketApi
exports.Conversions = Conversions
exports.Alphabet = Alphabet

exports.test = ()->

  cnv = Conversions
  fails = []
  for i in [10, 91, 200, 2000, 4123, 6540, 12000]
    s = cnv.to_s( i )
    puts "CONVERTING: #{ i } -> '#{ s }' -> ?"
    puts "conversion works: -- #{ yay = (tot=cnv.to_i( s )) is i }"
    puts "          = #{ tot }"
    fails.push i unless yay
  puts if fails.length > 0
    "FAILS: #{fails}"
  else "SUCCESSES!"

  puts "PADDING OUT A STRING:"

  puts "Padding out to 5 chars: #{cnv.e92.pad 'XXX', 5}"


# THOUGHTS ON TINY APIS:
# To build actual endpoint functions, need
#
# 1. Functions that return parsed vals (ints, strs)
# 2. The fn that knits them together into a call:
#    something like:
#
#  unpackCall player.do_something,
#    s2bImpulseVec(2,2)
#
#  unpackCall would give us the function that consumes
#  those portions of the string - so the return of the
#  _conversion_ fns needs to be multiple: [ val, rest ].


#-----------------
# so we want to use smaller WS messages, which are always utf-8 strings.
#
# using json in utf-8 strings is so wasteful it makes me want to cry ... but
# gzip helps with that.
#
# what it doesn't help with is the structure of the data:
#
#   FNAME ARG1:_, ARG2: _
#
# we don't need a full FNAME, and we know what order the args are in!
# So ideally we'd like a little lib that takes a hash of fnames and expected args
# and callbacks, and generates internally a much more compact mapping.
# We could also

#
#
# serverListens: [
#   consumeUserActions: cb
# ,
#   name2: cb
# ,
#   name3: cb
# ]
# clientListens: [
#   name: cb
# ]
#
# and you generate some api that listens for: '0':"somestring"
#
# and then I can unpack that in my object just fine, thank you.
# The API, the collection, and the user would all have something
# like `handlePackedMessage`
#
#
#  consumeUserActions: world.Users.handlePackedMessage
#
#
# ie, .handlePackedMessage = (msg)-> consumeMsg via passing it on.
# but for now, let's just do that basic thing: set up the integer
# map, above.