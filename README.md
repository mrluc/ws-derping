
Websocket Derping
===

A project to keep me sane until I'm back in Ecuador.

Node.js, Box2D, okay. Interesting enough. Going to add hammer.js
too, poke around, get dirty and learn a lot. Plus, connect-assets (meh, phased out in favor of
browserify and build script for coffeescript), and node-sass - yay for
awesome speed and designer familiarity.

Interesting Stuff
===


### Using Every Part of the Websocket Frame Buffalo

The Websockets standard is UTF-8, and people use it to send 
JSON. Socket.io uses json by default when you use `.on()` 
or `.emit()`, creating frames that look like

    5:::{"name":"myFn","args":[[1234,89352,123,392]]}

That's not optimal, but it doesn't need to be - the speed 
gain of websocket-versus-polling is so great that
optimizing the actual frames would be a waste of time for
lots of applications, especially since frames are often gzipped.

(Although for more general single-page-app projects, you're
probably already using something like backbone.js, and you
could just drop websockets in as a transport and get a nice speed boost).

But for some kinds of real-time, like multiplayer games, it makes
sense to have one really efficient channel to send updates along --
like player positions each tick.

You could just use `.send()` from the websockets standard, which
socket.io also provides, and send a delimited string
of updates -- for instance, two x/y pairs might be:

    3:::myFn[1234,89352,123,392]

That's clearly more efficient.

If you do that, you need to provide your own dispatch table - 
your own implementation of the `"name":"myFn"` part of the 
socket.io approach. A little logic, no big.

But there are still two sources of inefficiency:

- The function name. `myFn` is 4 bytes and it's not very 
  meaningful.
  
- The contents are base-10 numbers written in a base-255 
  medium: utf-8.
  
So that's what I played around with!

`TinySocketApi` takes care of the first part, and the a host of 
conversion, rpc and other little helpers take care of the second.


archi
===

Hmmm, missing compass as well ... node-sass is super-fast, but
from a designer's pov or working w/people, they'd want compass.

And there are great compass options. But making it all work both
precompiled AND dynamic ... I don't honestly see a great reason,
unless they're prohibitively slow.

The foolproof way of doing this all is
to recompile everything. Just have a build script and some
kind of watch script.

- Using [node-watch](https://npmjs.org/package/node-watch) maybe?
- We wouldn't need much granularity - re-running all build tasks can't
  be that bad.
  - ie, js-task and css-task watchers, splitting by asset type.
  - and vendor vs app watchers - split by dir

Let's just do a 'watch-everything, recompile-everything' approach.

- Switch based on dev env. For now, always-on task that runs this
  stuff.
  - 'If I hear a js change, re-browserify programatically'
    - And later, mo' fun.
  - 'If I hear a css change, compass' -- maybe later
    - for this project, just do your own scss stuff.

1. JS Browser logic
 -  [ ]  compile coffee from a src/ dir to a /js lib
 -  [X]  just connect-assets for that?
         tried, works
 -  [?]  browserify all of it
         TODO try this!!!!
