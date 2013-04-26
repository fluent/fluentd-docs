# Fluentd Docs App

Ultrasimple CMS and content for documentation of Fluentd.  The production site is [here](http://docs.fluentd.org/).

If you'd like to propose an edit to the Fluentd docs, fork this repo, then send us a pull request.

# Install

    $ gem install bundler
    $ bundle install --path vendor/bundle
    $ bundle exec rake server
    $ open "http://localhost:9395/"

# Build Search Index

    $ heroku run rake index

# Deploy

    $ git push heroku master

# Add other language

0. First, please create symlink to english article for preventing 404.

    $ cd docs
    $ make lang # e.g. de
    $ for f in *.txt; do ls lang/$f || ln -s ../$f lang/$f; done

after initialization, remove symlink and add translated article :)

# Acknowledgement

This program is forked from [heroku/heroku-docs](http://github.com/heroku/heroku-docs), and originally written by @rtomayko and @adamwiggins. Later, modified by @kzk and @doryokujin.

Code is released under the MIT License: http://www.opensource.org/licenses/mit-license.php

All rights reserved on the content (text files in the docs subdirectory), although you're welcome to modify these for the purpose of suggesting edits.
