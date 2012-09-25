Warble
======

The intelligent office jukebox...



Getting Started
---------------

You'll need a \*nix environment. Following are instructions for OS X 10.7:


### Prerequisites

Install [Xcode](http://developer.apple.com/tools/xcode/) and
[OS X GCC packages](https://github.com/kennethreitz/osx-gcc-installer).

Use [Homebrew](http://mxcl.github.com/homebrew/) to install
[Node.js](http://nodejs.org/), [Redis](http://redis.io/),
[rbenv](https://github.com/sstephenson/rbenv), and
[ruby-build](https://github.com/sstephenson/ruby-build).

```sh
$ brew install node redis rbenv ruby-build
```


### Build Ruby

Set up [rbenv](https://github.com/sstephenson/rbenv) for your shell:

```sh
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
```

**Reload your shell.**

Build and install Ruby 1.9.3:

```sh
$ rbenv install 1.9.3-p194   # Install MRI 1.9.3-p194
```

Add [Bundler](http://gembundler.com) for dependency management:

```sh
$ gem install bundler
$ rbenv rehash               # Rebuild the rbenv shim binaries
```


### Set up Node.js

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

Warble uses Facebook Connect to authenticate users. A Facebook _App ID_ and _App
Secret_ are expected in the `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET`
environment variables.

Create a new app at <http://facebook.com/developers>. Make sure to set the _Site
URL_ field to http://localhost:3000/.

[Foreman](http://ddollar.github.com/foreman/) loads environment variables from
`.env` in the project root when booting the app. Copy the Facebook _App ID_ and
_App Secret_ values:

```sh
$ echo 'FACEBOOK_APP_ID=111111111111111' >> .env
$ echo 'FACEBOOK_APP_SECRET=abcdefabcdefabcdefabcdefabcdefab' >> .env
```

Add credentials for a Pandora partner. Pick one from
http://pan-do-ra-api.wikia.com/wiki/Json/5/partners:

```sh
$ echo 'PANDORA_USERNAME=username' >> .env
$ echo 'PANDORA_PASSWORD=password' >> .env
$ echo 'PANDORA_DEVICE_ID=device_id' >> .env
$ echo 'PANDORA_ENCRYPTION_KEY=encryption_key' >> .env
$ echo 'PANDORA_DECRYPTION_KEY=decryption_key' >> .env
```

Copy the sample connection configurations:

```sh
$ cp config/redis.yml.sample config/redis.yml
$ cp config/database.yml.sample config/database.yml
```

Edit `config/redis.yml` and `config/database.yml` to match your local Redis and
PostgreSQL configuration.


### Running the application

Ensure Redis is running. You can find the proper incantations by running:

```sh
$ brew info redis
```

Start the web server, background processes, and other components with
[Foreman](http://ddollar.github.com/foreman/):

```sh
$ ./bin/foreman start
```

Now browse to <http://localhost:3000/> and get warbling!
