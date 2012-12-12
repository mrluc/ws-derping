

===

A project to keep me sane until I'm back in Ecuador.

Node.js, Box2D, okay. Interesting enough.

Plus, connect-assets (meh, phased out in favor of
browserify and build script for coffeescript), and node-sass - yay for
good speed and designer familiarity.


archi
===

Hmmm, missing compass as well ... node-sass is super-fast, but
from a designer's pov or working w/people, they'd want compass.

And there are great compass options. But making it all work both
precompiled AND dynamic ... I don't honestly see a great reason,
unless they're prohibitively slow.

The foolproof way of doing this all is
to recompile everything. A build script and some
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

Okay -- we went with browserify. The watch-everything,
compile-everything approach makes sense - but golly, 
if node-sass and browserify aren't enough for you, maybe
you should be using a 'real framework', whatever that is.

That's hot. Using the same modules+require process on client
and server makes me very hot. I need some air.