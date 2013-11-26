#!/bin/bash

# check that you have ruby
if [ `which ruby` == "" ]
then
    echo "ERROR: You need Ruby to run Fluentd!" 2>&1
    exit
fi

RUBY_VERSION=`ruby --version`
RUBY_VERSION=${RUBY_VERSION:5:3}

if [[ "$RUBY_VERSION" < "1.9" ]]
then
    echo "ERROR: You need Ruby 1.9 and above!" 2>&1
    exit
fi

NEEDED_GEMS="fluentd fluent-plugin-elasticsearch fluent-plugin-kibana-server fluent-plugin-embedded-elasticsearch"

for g in $NEEDED_GEMS
do
    gem install $g
done

curl -Ls http://docs.fluentd.org/misc/fluentd-kibana-elasticsearch/fluentd-kibana-elasticsearch.conf > test.conf
mkdir -p var/log/kibana

echo "DONE installing! Please run"
echo ""
echo "  fluentd -c test.conf"
echo ""
echo "to test drive Fluentd + Kibana + ElasticSearch."
echo "To visualize some data:"
echo ""
echo "  1. Visit http://localhost:8888/es/test?json={\"message\":\"hello\"}"
echo "  2. Visit http://localhost:24300/kibana/index.html#/dashboard/file/guided.json"
echo "  3. Play around in Kibana!"
echo ""
echo "Learn more about Fluentd at https://fluentd.org"
