# -*- coding: utf-8 -*-

section 'overview', 'Overview' do
  category 'getting-started', 'Getting Started' do
    article 'quickstart', 'Getting Started with Fluentd'
  end
  category 'installation', 'Installation' do
    article 'before-install', 'Before Installing Fluentd'
    article 'install-by-docker', 'Installing Fluentd with Docker'
    article 'install-by-rpm', 'Installing Fluentd using RPM Package (Redhat Linux)'
    article 'install-by-deb', 'Installing Fluentd using DEB Package (Debian / Ubuntu Linux)'
    article 'install-by-dmg', 'Installing Fluentd using .dmg Package (MacOS X)'
    article 'install-by-gem', 'Installing Fluentd using Ruby Gem'
    article 'install-by-chef', 'Installing Fluentd using Chef'
    article 'install-from-source', 'Installing Fluentd from Source'
    article 'install-on-heroku', 'Installing Fluentd on Heroku'
    article 'install-on-beanstalk', 'Installing Fluentd on AWS Elastic Beanstalk'
  end
  category 'support', 'Support' do
    article 'support', 'Support'
  end
  category 'faq', 'FAQ' do
    article 'faq', 'FAQ'
  end
end
section 'usecases', 'Use Cases' do
  category 'container-logging', 'Container Logging' do
    article 'docker-logging', 'Docker Logging Driver and Fluentd'
    article 'docker-logging-efk-compose', 'Collect Docker Logs via EFK (Elasticsearch + Fluentd + Kibana) with Docker Compose'
  end
  category 'logging-from-apps', 'Centralized App Logging' do
    article 'java',   'Centralize Logs from Java Applications'
    article 'ruby',   'Centralize Logs from Ruby Applications'
    article 'python', 'Centralize Logs from Python Applications'
    article 'php',    'Centralize Logs from PHP Applications'
    article 'perl',   'Centralize Logs from Perl Applications'
    article 'nodejs', 'Centralize Logs from Node.js Applications'
    article 'scala',   'Centralize Logs from Scala Applications'
  end
  category 'log-management-and-search', 'Log Management & Search' do
    article 'free-alternative-to-splunk-by-fluentd', 'Free Alternative to Splunk by Fluentd + Elasticsearch', ['Splunk', 'Free Alternative']
    article 'filter-modify-apache', 'Filter and Modify Data (Apache example)'
    article 'splunk-like-grep-and-alert-email', 'Email Alerts like Splunk', ['Splunk', 'Alerting']
  end
  category 'data-analytics', 'Data Analytics' do
    article 'http-to-td', 'Data Analytics with Treasure Data', ['Treasure Data', 'Hadoop', 'Hive']
    article 'http-to-hdfs', 'Data Collection to Hadoop (HDFS)', ['Hadoop', 'HDFS']
    article 'apache-to-mongodb', 'Store Apache Logs into MongoDB', ['MongoDB']
  end
  category 'data-archiving', 'Data Archiving' do
    article 'apache-to-s3', 'Store Apache Logs into Amazon S3', ['Amazon S3']
    article 'apache-to-riak', 'Store Apache Logs into Riak', ['Riak']
    article 'collect-glusterfs-logs', 'Collecting GlusterFS Logs', ['GlusterFS']
  end
  category 'stream-processing', 'Stream Processing' do
    article 'kinesis-stream', 'Stream Data Collection to Kinesis Stream', ['kinesis', 'amazon kinesis', 'aws kinesis']
    article 'cep-norikra', 'Fluentd and Norikra: Complex Event Processing', ['cep-norikra']
  end
  category 'windows', 'Windows Event Collection' do
    article 'windows', 'Windows Event Collection'
  end
  category 'iot', 'IoT Data Logger' do
    article 'raspberrypi-cloud-data-logger', 'Raspberry Pi Cloud Data Logger', ['Raspberry Pi', 'Data Logger', 'Data Acquisition']
  end
end
section 'configuration', 'Configuration' do
  category 'config-file', 'Config File Syntax' do
    article 'config-file', 'Config File Syntax'
  end
  category 'routing-examples', 'Routing Examples' do
    article 'routing-examples', 'Routing Examples'
  end
  category 'recipes', 'Recipes' do
    article "common-log-formats", "Parsing Common Log Formats"
    for recipe in Dir.entries("#{settings.root}/docs/v0.12").grep(/^recipe-/)
      recipe.chomp!(".txt")
      article recipe, (recipe.split("-").map {|w|
        if /json|csv|tsv/.match(w)
          w.upcase
        else
          w.capitalize
        end
      }).join(" ")
    end
  end
end
section 'deployment', 'Deployment' do
  category 'logging', 'Logging' do
    article 'logging', 'Logging'
  end
  category 'monitoring', 'Monitoring' do
    article 'monitoring', 'Monitoring'
  end
  category 'signals', 'Signals' do
    article 'signals', 'Signal Handling', ['Signals']
  end
  category 'rpc', 'RPC' do
    article 'rpc', 'HTTP RPC'
  end
  category 'high-availability', 'High Availability Config' do
    article 'high-availability', 'Fluentd High Availability Configuration'
  end
  category 'failure-scenarios', 'Failure Scenarios' do
    article 'failure-scenarios', 'Failure Scenarios'
  end
  category 'performance-tuning', 'Performance Tuning' do
    article 'performance-tuning', 'Performance Tuning'
  end
  category 'plugin-management', 'Plugin Management' do
    article 'plugin-management', 'Plugin Management'
  end
  category 'trouble-shooting', 'Trouble Shooting' do
    article 'trouble-shooting', 'Trouble Shooting'
  end
  category 'security', 'Security' do
    article 'forwarding-over-ssl', 'SSL-Enabled Transport', ['Security', 'SSL']
  end
  category 'fluentd-ui', 'Fluentd UI' do
    article 'fluentd-ui', 'Fluentd UI'
  end
  category 'command-line-option', 'Command Line Option' do
    article 'command-line-option', 'Fluentd commands and options'
  end
end
section 'plugin', 'Input Plugins' do
  category 'input-plugin-overview', 'Overview' do
    article 'input-plugin-overview', 'Input Plugin Overview'
  end
  category 'in_udp', 'in_udp' do
    article 'in_udp', 'UDP Input Plugin'
  end
  category 'in_tcp', 'in_tcp' do
    article 'in_tcp', 'TCP Input Plugin'
  end
  category 'in_forward', 'in_forward' do
    article 'in_forward', 'forward Input Plugin'
  end
  category 'in_secure_forward', 'in_secure_forward' do
    article 'in_secure_forward', 'secure_forward Intput Plugin', ['SSL', 'authentication']
  end
  category 'in_http', 'in_http' do
    article 'in_http', 'http Input Plugin'
  end
  category 'in_unix', 'in_unix' do
    article 'in_unix', 'UDS Input Plugin'
  end
  category 'in_tail', 'in_tail' do
    article 'in_tail', 'tail Input Plugin'
  end
  category 'in_exec', 'in_exec' do
    article 'in_exec', 'exec Input Plugin'
  end
  category 'in_syslog', 'in_syslog' do
    article 'in_syslog', 'syslog Input Plugin', ['Syslog']
  end
  category 'in_scribe', 'in_scribe' do
    article 'in_scribe', 'scribe Input Plugin', ['Scribe', 'Facebook']
  end
  category 'in_multiprocess', 'in_multiprocess' do
    article 'in_multiprocess', 'Multi-Process Input Plugin'
  end
  category 'in_dummy', 'in_dummy' do
    article 'in_dummy', 'Dummy Input Plugin'
  end
  category 'in_others', 'Others' do
    article 'in_others', 'Other Input Plugins'
  end
end
section 'output-plugins', 'Output Plugins' do
  category 'output-plugin-overview', 'Overview' do
    article 'output-plugin-overview', 'Output Plugin Overview'
  end
  category 'out_file', 'out_file' do
    article 'out_file', 'file Output Plugin'
  end
  category 'out_forward', 'out_forward' do
    article 'out_forward', 'forward Output Plugin'
  end
  category 'out_secure_forward', 'out_secure_forward' do
    article 'out_secure_forward', 'secure_forward Output Plugin', ['SSL', 'authentication']
  end
  category 'out_exec', 'out_exec' do
    article 'out_exec', 'exec Output Plugin'
  end
  category 'out_exec_filter', 'out_exec_filter' do
    article 'out_exec_filter', 'exec_filter Output Plugin'
  end
  category 'out_copy', 'out_copy' do
    article 'out_copy', 'copy Output Plugin'
  end
  category 'out_geoip', 'out_geoip' do
    article 'out_geoip', 'GeoIP Output Plugin'
  end
  category 'out_roundrobin', 'out_roundrobin' do
    article 'out_roundrobin', 'roundrobin Output Plugin'
  end
  category 'out_stdout', 'out_stdout' do
    article 'out_stdout', 'stdout Output Plugin'
  end
  category 'out_null', 'out_null' do
    article 'out_null', 'null Output Plugin'
  end
  category 'out_s3', 'out_s3' do
    article 'out_s3', 'S3 Output Plugin', ['Amazon S3', 'AWS', 'Simple Storage Service']
  end
  category 'out_kafka', 'out_kafka' do
    article 'out_kafka', 'Kafka Output Plugin'
  end
  category 'out_mongo', 'out_mongo' do
    article 'out_mongo', 'MongoDB Output Plugin', ['MongoDB']
  end
  category 'out_mongo_replset', 'out_mongo_replset' do
    article 'out_mongo_replset', 'MongoDB ReplicaSet Output Plugin', ['MongoDB', 'Mongo']
  end
  category 'out_relabel', 'out_relabel' do
    article 'out_relabel', 'relabel Output Plugin'
  end
  category 'out_rewrite_tag_filter', 'out_rewrite_tag_filter' do
    article 'out_rewrite_tag_filter', 'rewrite_tag_filter Output Plugin'
  end
  category 'out_webhdfs', 'out_webhdfs' do
    article 'out_webhdfs', 'WebHDFS Output Plugin', ['Hadoop', 'HDFS']
  end
  category 'out_others', 'Others' do
    article 'out_others', 'Other Output Plugins'
  end
end
section 'buffer-plugins', 'Buffer Plugins' do
  category 'buffer-plugin-overview', 'Overview' do
    article 'buffer-plugin-overview', 'Buffer Plugin Overview'
  end
  category 'buf_memory', 'buf_memory' do
    article 'buf_memory', 'memory Buffer Plugin'
  end
  category 'buf_file', 'buf_file' do
    article 'buf_file', 'file Buffer Plugin'
  end
end
section 'filter-plugins', 'Filter Plugins' do
  category 'filter-plugin-overview', 'Overview' do
    article 'filter-plugin-overview', 'Filter Plugin Overview'
  end
  category 'filter_record_transformer', 'filter_record_transformer' do
    article 'filter_record_transformer', 'record_transformer Filter Plugin'
  end
  category 'filter_grep', 'filter_grep' do
    article 'filter_grep', 'grep Filter Plugin'
  end
  category 'filter_parser', 'filter_parser' do
    article 'filter_parser', 'parser Filter Plugin'
  end
  category 'filter_stdout', 'filter_stdout' do
    article 'filter_stdout', 'stdout Filter Plugin'
  end
end
section 'parser-plugins', 'Parser Plugins' do
  category 'parser-plugin-overview', 'Overview' do
    article 'parser-plugin-overview', 'Parser Plugin Overview'
  end
end
section 'formatter-plugins', 'Formatter Plugins' do
  category 'formatter-plugin-overview', 'Overview' do
    article 'formatter-plugin-overview', 'Formatter Plugin Overview'
  end
end
section 'developer', 'Developer' do
  category 'plugin-development', 'Plugin Development' do
    article 'plugin-development', 'Plugin Development'
  end
  category 'life-of-a-fluentd-event', 'Life of a Fluentd Event' do
    article 'life-of-a-fluentd-event', 'Life of a Fluentd Event'
  end
  category 'community', 'Community' do
    article 'community', 'Community'
  end
  category 'mailing-list', 'Mailing List' do
    article 'mailing-list', 'Mailing List'
  end
  category 'source-code', 'Source Code' do
    article 'source-code', 'Source Code'
  end
  category 'bug-tracking', 'Bug Tracking' do
    article 'bug-tracking', 'Bug Tracking'
  end
  category 'changelog', 'ChangeLog' do
    article 'changelog', 'ChangeLog'
  end
  category 'logo', 'Logo' do
    article 'logo', 'Logo'
  end
end
section 'enterprise-edition', 'Enterprise Edition' do
  category 'enterprise-support-portal', 'Support Portal' do
    article 'enterprise-support-portal', 'Support Portal'
  end
end
