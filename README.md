Warble
======

The intelligent office jukebox...


Getting Started
---------------

You'll need a \*nix environment. Following are instructions for OS X 10.6:

### Prerequisites:

1. Install [Xcode](http://developer.apple.com/tools/xcode/).

2. Install [Git](http://git-scm.org), [Node.js](http://nodejs.org/) and
   [Redis](http://redis.io/). If you use
   [homebrew](http://mxcl.github.com/homebrew/) for package management, then

        $ brew install git node redis

### Installing ruby:

1. Install [RVM](http://rvm.beginrescueend.com/) to help create sandboxed ruby
   environments. Inspect the script if you're wary of executing scripts directly
   off the internet:

        $ bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )

   _Make sure you follow the post-install instructions and reload your
   terminal._

2. Install the latest patch release of ruby 1.9.2 and add
   [Bundler](http://gembundler.com) for dependency management.

        $ rvm install 1.9.2
        $ rvm 1.9.2@global
        $ gem install bundler
        $ rvm 1.9.2

### Setup Node.js:

1. Install [npm](http://npmjs.org/) to manage node.js libraries. Inspect the
   script if you're wary of executing scripts directly off the internet:

        $ curl http://npmjs.org/install.sh | sh

2. Add `NODE_PATH` to your `~/.bash_profile` or `~/.zshrc`. Assuming you use
   homebrew installed at `/usr/local`, add the following:

        export NODE_PATH=/usr/local/lib/node

3. Install dependent node.js libraries:

        $ npm install redis socket.io coffee-script

### Preparing the project

1. Clone the repository:

        $ git clone git@github.com:nixme/warble.git
        $ cd warble

2. Create a sandboxed ruby environment and install dependent gems:

        $ rvm --rvmrc 1.9.2@warble
        $ bundle install

   *Note:* This drops a `.rvmrc` file in the project which will automatically
   switch environment variables for the sandboxed ruby when you change
   directory into the project. The next time you enter this directory, you'll
   get a warning about trusting the file. Make sure you accept!

### Running the application server

1. Ensure Redis is running. If installed via homebrew, you can find the
   incantations to start it by running:

        $ brew info redis

2. Start the node.js websocket relay:

        $ coffee server.coffee

3. Start at least one background worker, adjust `COUNT` for more:

        $ COUNT=1 QUEUE=* rake resque:workers

4. Start the bundled Solr engine for full-text search:

        $ rake sunspot:solr:start

5. Start the ruby web server:

        $ thin start

Now browse to <http://localhost:3000/> and get warbling!
