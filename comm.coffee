
_ = require 'underscore'
ext = require('./extensions')

Module = ext.Module

class Conversions
  bs = (i,len=8,pad="0")->
    s = i.toString 2
    amt = len - (s.length % len)
    s = pad+s for i in [1..amt]
    s

  @utf2int = (chars)->
    bstr = ""
    for i in [ 0..chars.length-1 ]
      bstr += bs chars.charCodeAt(i)
    parseInt bstr, 2

  @int2utf = (int)->
    bstr = bs int
    bytes = Math.ceil( bstr.length / 8 )
    utf = ""
    for idx in [0..(bytes-1)]
      chunk = bstr.slice (idx*8), (idx*8)+8 # 8 == byte
      utf += String.fromCharCode parseInt( chunk, 2 )

    utf



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

exports.TinySocketApi = TinySocketApi
exports.Conversions = Conversions


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