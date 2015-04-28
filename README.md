# Fluentd Docs App

Ultrasimple CMS and content for Fluentd documentation. The production site is [here](http://docs.fluentd.org/).

If you'd like to propose an edit to the Fluentd docs, please fork this repo and send us a pull request.

## Multiple language support

English article is maintained by Fluentd team.
Another language article, e.g. ja, is maintained by the community.
So some articles may be outdated.
If you find outdated article, please send pull request to this repository.

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

    $ git push heroku master

## NOTE

When you have updated an article, please update config/last_updated.json too.

    $ bundle exec rake last_updated
    $ git add config/last_updated.json

# Add Another Language

0. First, please create a symlink to the English article in order to prevent a 404 response.

    $ cd docs
    $ make lang # e.g. de
    $ for f in *.txt; do ls lang/$f || ln -s ../$f lang/$f; done

After initialization, please remove the symlink and add the translated article. :)

# Contributing docs for v1

v1 docs are under docs/v1. Currently, most articles are symlinked to the corresponding file in docs/.

- If you are updating an exiting article. Just replace the symlink with an actual article.
- If you are adding a new article, just add it under docs/v1.

Once v1 is released, this process will be updated.

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
