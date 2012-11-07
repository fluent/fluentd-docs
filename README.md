# TD Docs App

Ultrasimple CMS and content for documentation of Fluentd.  The production site is [here](http://docs.fluentd.org/).

If you'd like to propose an edit to the TD docs, fork this repo, then send us a pull request.

# Install

    $ gem install bundler
    $ bundle install --path vendor/bundle
    $ bundle exec rake server
    $ open "http://localhost:9393/articles/quickstart"

# Build Search Index

    $ bundle exec rake indexing

# Deploy

    $ git push heroku master

# Acknowledgement

This program is forked from [heroku/heroku-docs](http://github.com/heroku/heroku-docs), and originally written by Ryan Tomayko and Adam Wiggins. Later, modified by Kazuki Ohta and Takahiro Inoue.

Code is released under the MIT License: http://www.opensource.org/licenses/mit-license.php

All rights reserved on the content (text files in the docs subdirectory), although you're welcome to modify these for the purpose of suggesting edits.
