
Websocket Derping
===

A project to keep me sane until I'm back in Ecuador. Playing around
with websockets, thinking about multiplayer.

Node.js, Box2D, okay. Interesting enough just to get running. Code sharing on
client and server is already a liberating experience with browserify.
Going to add hammer.js too, poke around, get dirty, learn. And yay for node-sass.

Fun stuff so far:

* [Every Part of the Websocket Buffalo](#buffalo)

<span id="buffalo">
#### Every Part of the Websocket Buffalo

The Websockets standard is UTF-8, and people often use it to 
send JSON. Socket.io uses JSON by default when you use `.on()` 
or `.emit()`, so that

    socket.emit 'myFn', [{id:1,x:2,y:3}]

    # creates websocket frames like:

    5:::{"name":"myFn","args":[[{"id":1,"x":2,"y":3}]]}

That's not optimal, but it's not trying to be optimal in that
sense, and doesn't need to be - the benefit of  
open-socket-versus-polling is so great that optimizing the actual frames would be 
a waste of time for almost anyone, especially since 
frames are often gzipped.

And in fact for more general single-page-app projects, you're
probably already using something like backbone.js that sends hashes
back and forth, and you can drop websockets in as a transport and get a nice 
speed boost.

But for some kinds of real-time, like multiplayer games, it makes
sense to have one channel that's really optimized for the core
updates, like entity positions each tick.

You could just use `.send()` from the websockets standard, which
socket.io also provides, and send a delimited separated sequence
of updates -- for instance, two x/y pairs might be:

    3:::myFn[1234,89352,123,392]

That's a lot smaller. You need to provide your own dispatch table - 
your own implementation of the `"name":"myFn"` part of the 
socket.io approach. A little logic, no big.

But there are still two sources of inefficiency:

1. The function name. `myFn` is 4 bytes long. Seems short, but
   how many functions are there in your API brah?? `Math.pow(58, 4)` 
   functions??
   
2. The contents are base-10 numbers written in a base-255
   medium: utf-8.
   
   In practice we can only use from base-58
   to base-93, and utf-8 is actually only base-128 for our 
   purposes, but any of that would be 
   quite an improvement on base-10!
   
   gzip would whittle down the improvement with larger message
   bodies, but the nature of websocket frames is that they'll
   likely be smallish and frequent.
   
So that's what I played around with first! There are some classes
sketched out around this that I'll probably extract out into 
a little library before continuing on with my merry
muckery.

`TinySocketApi` (built on `CompressedKeys`) takes care 
of the first point, and then a host of conversion, 
rpc and other little helpers (`CompilingApiCall`,
`Coder`,`PackedCalls`,`Conversions`,`Alphabet` - I know, I know) take 
care of the second. `TinySocketApi` also handles binding 
of sockets for the server and the client.

None of this is necessary - gzipped frames are probably fine -
but it's been fun - and now we can send some ints via

    socket.gameState [parseInt(pos.x), parseInt(pos.y), 92*92, 92*93]

And the message produced will be

    3:::1`6~-Y`Z~

Instead of, for instance:

    3:::'gameState',106,24,8464,8556

It's comforting to know the exact size of the messages 
we send. We can start reasoning on what's possible, and make informed
tradeoffs re: number of messages and their weight and number of clients.


archi
===

#### Asset Notes

The foolproof way of handling asset stuff is just
to recompile everything. A build script and some
kind of watch script.

- Using [node-watch](https://npmjs.org/package/node-watch) maybe?
- We wouldn't need much granularity - re-running all asset build tasks
  is only slow in Rails.
  - ie, js-task and css-task watchers, splitting by asset type.
  - and vendor vs app watchers - split by dir

Okay -- we went with browserify. The watch-everything,
compile-everything approach makes sense - but golly, 
if node-sass and browserify aren't enough for you, maybe
you should be using a 'real framework', of which there are several.

