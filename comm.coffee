
_ = require 'underscore'
ext = require('./extensions')

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
  to_s: (i)=>
    @toAlphabet i, @byPosition
  to_i: (s)=>
    digits = s.split ""
    [len, num] = [digits.length, 0]
    num += Math.pow(@byLetter[s], len-i) for s, i in digits
    num

class Conversions extends Module
  @include require 'bases'
  @e92 = new Alphabet [
    "~`!1@2#3$4%5^6&7*8(9)0"
    " _-+={[}]|:;<,>.?/"
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  ].join ''
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

class TinySocketApi extends Module
  @include _
  constructor: ({@serverListens, @clientListens})->
    @serverApi = new CompressedKeys @serverListens
    @clientApi = new CompressedKeys @clientListens

  setSocket: (sock, api)->
    sock.on evt, cb for evt, cb of api.tiny

  serverListen: (sock)=>  @setSocket sock, @serverApi
  clientListen: (sock)=>  @setSocket sock, @clientApi

class CallUnpacker extends Module


exports.TinySocketApi = TinySocketApi
exports.Conversions = Conversions
exports.Alphabet = Alphabet


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