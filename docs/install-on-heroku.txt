# Install Fluentd (td-agent) on Heroku

This article describes how to install Fluentd (td-agent) on [Heroku](http://www.heroku.com/).

## With non-Treasure Data backend

Heroku doesn't allow users to install separate processes within a single dyno. You will thus need to setup Fluentd as a separate Heroku application. This will become you central log aggregation server.

Treasure Data provides a boilerplate repository to get you started. Follow the steps below to create Fluentd (td-agent) as a Heroku application.

    :::term
    # Clone
    $ git clone git://github.com/treasure-data/heroku-td-agent.git
    $ cd heroku-td-agent
    $ rm -fR .git
    $ git init
    $ git add .
    $ git commit -m 'initial commit'
    
    # Create the app & deploy
    $ heroku create --stack cedar
    $ git push heroku master

    # Update your config
    $ vi td-agent.conf
    $ git commit -a -m 'update config file'
    
    # Deploy
    $ git push heroku master



## With Treasure Data as a Backend

Since [Treasure Data](http://www.treasuredata.com), the primary sponsor of Fluentd, is a [Heroku Addons provider](https://addons.heroku.com/treasure-data), some of you came here to stream data to Treasure Data through Fluentd.

If

    :::text
              http                          
    Your App ------> Heroku-hosted Fluentd ------> Treasure Data

is what you want, there are two ways to deploy it.

### 1. Heroku Button

Clicking on the following button automatically launched td-agent on Heroku:

<a href="https://heroku.com/deploy?template=https://github.com/treasure-data/heroku-td-agent"><img src="https://www.herokucdn.com/deploy/button.png"/></a>

You can read more about this approach [here](https://github.com/treasure-data/heroku-td-agent).

### 2. Using Git

This is similar to "With non-Treasure Data Backend", except you do not need to edit the config. Instead, simply update the configuration variable:

    :::term
    # Clone
    $ git clone git://github.com/treasure-data/heroku-td-agent.git
    $ cd heroku-td-agent
    $ rm -fR .git
    $ git init
    $ git add .
    $ git commit -m 'initial commit'
    
    # Create the app & deploy
    $ heroku create --stack cedar
    $ git push heroku master

    # Set your config
    $ heroku config:set TREASURE_DATA_API_KEY=you_treasure_data_api_key_value
    
    # Deploy
    $ git push heroku master

To retrieve your `treasure_data_api_key_value`, see [here](http://docs.treasuredata.com/articles/get-apikey).

## Test

Let's confirm that the log aggregation server has been set up correctly. Please send a GET request to the log server, http://td-agent-on-heroku.herokuapp.com, as shown below. This will log the event { "json": "message" } with a debug.sample tag. Note how the JSON-formatted data is passed as a query parameter value.

    :::term
    $ curl "http://td-agent-on-heroku.herokuapp.com/debug.sample?json=%7B%22json%22%3A%22message%22%7D"

In general, the URL format is

    :::term
    http://{YOUR LOG SERVER DOMAIN}/td.{DB_NAME}.{TABLE_NAME}?json={JSON_FORMATTED_DATA}

The output will be available on STDOUT.

    :::term
    $ heroku logs --tail
