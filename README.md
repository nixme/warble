Warble
======

The intelligent office jukebox...


Installation
------------

OS X 10.6 instructions. Install the following:

1. [Xcode](http://developer.apple.com/tools/xcode/).
2. [homebrew](http://mxcl.github.com/homebrew/).
3. [Git](http://git-scm.org), [node.js](http://nodejs.org),
   [Redis](http://redis.io/) via homebrew:

        brew install git node redis

5. [RVM](http://rvm.beginrescueend.com/):

        bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )

   Make sure you follow the post-install instructions and reload your terminal.

6. [npm](http://npmjs.org/):

        curl http://npmjs.org/install.sh | sh

7. node libraries redis, socket.io, coffee-script via npm:

        npm install redis socket.io coffee-script

8. rvm gemset...

9. To run: start redis, `coffee server.coffee`, `thin start`,
   `COUNT=2 QUEUE=* rake resque:workers`, `rake sunspot:solr:start`

10. Browse to <http://localhost:3000>
