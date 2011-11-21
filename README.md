Warble
======

The intelligent office jukebox...



Getting Started
---------------

You'll need a \*nix environment. Following are instructions for OS X 10.7:


### Prerequisites:

Install [Xcode](http://developer.apple.com/tools/xcode/) and
[OS X GCC packages](https://github.com/kennethreitz/osx-gcc-installer).

Use [Homebrew](http://mxcl.github.com/homebrew/) to install
[Node.js](http://nodejs.org/), [Redis](http://redis.io/),
[rbenv](https://github.com/sstephenson/rbenv), and
[ruby-build](https://github.com/sstephenson/ruby-build).

```sh
$ brew install node redis rbenv ruby-build
```


### Building Ruby:

Set up [rbenv](https://github.com/sstephenson/rbenv) for your shell:

```sh
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
```

_Reload your shell._

Build and install the latest patch release of ruby 1.9.3. Add
[Bundler](http://gembundler.com) for dependency management.

```sh
$ rbenv install 1.9.3-p0   # Install the latest MRI 1.9.3
$ rbenv rehash             # Rebuild the shim binaries
$ gem install bundler      # Install bundler
```


### Setup Node.js:

Install [npm](http://npmjs.org/) to manage node.js dependencies. Inspect the
script if you're wary of executing scripts directly off the internet:

```sh
$ curl http://npmjs.org/install.sh | sh
```


### Preparing the project

Install dependencies:

```sh
$ bundle install --binstubs    # Ruby dependencies
$ cd push
$ npm install                  # Node.js dependencies
$ cd ..
```

Warble uses Facebook Connect to authenticate users. Create a new app at
<http://facebook.com/developers>. Make sure to set the _Site URL_ field to
http://localhost:3000/.

Copy the _App ID_ and _App Secret_ values to environment variables in your
shell. I recommend adding them to `~/.bash_profile` or appropriate shell
startup script and then reloading the shell:

```sh
$ echo 'export FACEBOOK_APP_ID="111111111111111"' >> ~/.bash_profile
$ echo 'export FACEBOOK_APP_SECRET="abcdefabcdefabcdefabcdefabcdefab"' >> ~/.bash_profile
```


### Running the application

Ensure Redis is running. You can find the proper incantations by running:

```sh
$ brew info redis
```

Start a local Solr search server in a separate shell:

```sh
$ ./bin/rake sunspot:solr:run
```

Start the web server, background processes, and other components with
[Foreman](http://ddollar.github.com/foreman/):

```sh
$ ./bin/foreman start
```

Now browse to <http://localhost:3000/> and get warbling!
