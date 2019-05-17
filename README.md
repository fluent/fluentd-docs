# Fluentd Docs App

# Important Warnings

**THE OFFICIAL DOCUMENTATION FOR FLUENTD HAS BEEN MOVED TO GITBOOK**

This repository is kept as a historical archive. If you find something
wrong on https://docs.fluentd.org, please submit issues or PRs to the new
GitBook repository.

https://github.com/fluent/fluentd-docs-gitbook

# Overview

Ultrasimple CMS and content for Fluentd documentation. The production site is [here](https://docs.fluentd.org/).

If you'd like to propose an edit to the Fluentd docs, please fork this repo and send us a pull request.

Note that we require each commit to be signed off by the author as policy. Thus, when writing a patch, please sign your commit using the `-s` option.

    # Append `--amend` to sign the previous commit
    $ git commit -s

# Install

    $ gem install bundler
    $ bundle install --path vendor/bundle
    $ bundle exec rake server
    $ open "http://localhost:9395/"

# Test

    $ bundle exec rake test

# Build Search Index

    $ heroku run rake index

# Deploy

We deploy fluentd-docs by Circle-CI automatically.
If you want to deploy it manually, run following command.

    $ git push heroku master

## NOTE

When you have updated an article, please update config/last_updated.json too.

    $ bundle exec rake last_updated
    $ git add config/last_updated.json

# Contributing docs for v1

v1 docs are under docs/v1. Currently, most articles are symlinked to the corresponding file in docs/.

- If you are updating an exiting article. Just replace the symlink with an actual article.
- If you are adding a new article, just add it under docs/v1.

Once v1 is released, this process will be updated.

# INCLUDE pragma

You can use the "INCLUDE pragma" to avoid copy-and-pasting the same content or updates on multiple pages.

The syntax is as follows:

    INCLUDE: <filename without extension>

    ... the rest of the document.

Please remember to include a blank line between "INCLUDE..." and the rest of the document.
The docs app will search for \<filename\>.txt in the `docs` directory and insert its contents into the current document.

For example, if you write

    INCLUDE: _buffer_parameters

    ... the rest of the document.

then the docs app will insert the contents of \_buffer\_parameters.txt into the current document.

# Acknowledgement

This program is forked from [heroku/heroku-docs](http://github.com/heroku/heroku-docs), and originally written by @rtomayko and @adamwiggins. Later, modified by @kzk and @doryokujin.

Code is released under the MIT License: http://www.opensource.org/licenses/mit-license.php

All rights reserved on the content (text files in the docs subdirectory), although you're welcome to modify these for the purpose of suggesting edits.
