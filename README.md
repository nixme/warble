Warble
======

The intelligent office jukebox...



Getting Started
---------------

You'll need a \*nix environment. Following are instructions for OS X 10.6:


### Prerequisites:

Install [Xcode](http://developer.apple.com/tools/xcode/).

Install [Git](http://git-scm.org), [Node.js](http://nodejs.org/) and
[Redis](http://redis.io/). If you use
[homebrew](http://mxcl.github.com/homebrew/) for package management, then

```sh
$ brew install git node redis
```


### Installing ruby:

Install [RVM](http://rvm.beginrescueend.com/) to help create sandboxed ruby
environments. Inspect the script if you're wary of executing scripts directly
off the internet:

```sh
$ bash < <(curl -s http://rvm.beginrescueend.com/install/rvm)
$ echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile
```

_Make sure you follow any post-install instructions and reload your
terminal._

Install the latest patch release of ruby 1.9.2 and add
[Bundler](http://gembundler.com) for dependency management.

```sh
$ rvm install 1.9.2      # install the latest MRI/YARV 1.9.2
$ rvm 1.9.2@global       # switch to 1.9.2's global gemset
$ gem install bundler    # install bundler
$ rvm --default 1.9.2    # set 1.9.2 as the default ruby
```


### Setup Node.js:

Install [npm](http://npmjs.org/) to manage node.js libraries. Inspect the script
if you're wary of executing scripts directly off the internet:

```sh
$ curl http://npmjs.org/install.sh | sh
```

Add `NODE_PATH` to your `~/.bash_profile` or appropriate shell startup script.
Assuming you use homebrew installed at `/usr/local` and use bash, run the
following:

```sh
$ echo 'export NODE_PATH="/usr/local/lib/node"' >> ~/.bash_profile
```

Install dependent node.js libraries:

```sh
$ npm install redis socket.io coffee-script
```


### Preparing the project

Clone the repository:

```sh
$ git clone git@github.com:nixme/warble.git
$ cd warble
```

Create a sandboxed ruby environment and install dependent gems:

```sh
$ rvm --create --rvmrc 1.9.2@warble
$ bundle install
```

*Note:* This drops a `.rvmrc` file in the project which will automatically
switch environment variables for the sandboxed ruby when you change
directory into the project. The next time you enter this directory, you'll
get a warning about trusting the file. Make sure you accept!

Warble uses Facebook Connect to authenticate users. Create a new app at
<http://facebook.com/developers>. Make sure to set the _Site URL_ field to
http://localhost:5000/.

Copy the _App ID_ and _App Secret_ values to environment variables in your
shell. I recommend adding them to `~/.bash_profile` or appropriate shell
startup script and then reloading the shell:

```sh
$ echo 'export FACEBOOK_APP_ID="111111111111111"' >> ~/.bash_profile
$ echo 'export FACEBOOK_APP_SECRET="abcdefabcdefabcdefabcdefabcdefab"' >> ~/.bash_profile
```


### Running the application

Ensure Redis is running. If installed via homebrew, you can find the
proper incantations to start it by running:

```sh
$ brew info redis
```

Start the web server, search server, background processes, and other
components with [Foreman](http://ddollar.github.com/foreman/):

```sh
$ foreman start
```

Now browse to <http://localhost:5000/> and get warbling!
