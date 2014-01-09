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

## NOTE

When updated the article, please update config/last_updated.json too.

    $ bundle exec rake last_updated
    $ git add config/last_updated.json

# Add other language

0. First, please create symlink to english article for preventing 404.

    $ cd docs
    $ make lang # e.g. de
    $ for f in *.txt; do ls lang/$f || ln -s ../$f lang/$f; done

after initialization, remove symlink and add translated article :)

# Detect outdated documents

    $ bundle exec rake outdated
    docs/ja/config-file.txt    : 4 days, 10 hours
    docs/ja/install-by-gem.txt : 13 hours
    docs/ja/out_mongo.txt      : 153 days, 19 hours
    docs/ja/quickstart.txt     : 14 hours
    Following articles not to exist in "br":
      changelog.txt
      config-file.txt
      faq.txt
    Following article not to exist in "eu":
      java.txt
    Following articles not to exist in "la":
      apache-to-mongodb.txt
      apache-to-s3.txt

# INCLUDE pragma

In order to avoid copy-and-pasting the same content on multiple pages, one can
use the "INCLUDE pragma".

The syntax is as follows

    INCLUDE: <filename>
    
    blah blah blah...

(Notice that there is a blank line between "INCLUDE..." and "blah blah blah...")
Then, the docs app will search for <filename>.txt in the `docs` directory. For
example, if you write

    INCLUDE: _buffer_parameters

    blah blah blah...

The docs app would insert the content of _buffer_parameters.txt into the docs
page.

# Acknowledgement

This program is forked from [heroku/heroku-docs](http://github.com/heroku/heroku-docs), and originally written by @rtomayko and @adamwiggins. Later, modified by @kzk and @doryokujin.

Code is released under the MIT License: http://www.opensource.org/licenses/mit-license.php

All rights reserved on the content (text files in the docs subdirectory), although you're welcome to modify these for the purpose of suggesting edits.
