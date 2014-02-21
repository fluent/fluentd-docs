# -*- coding: utf-8 -*-

section 'overview', 'Overview' do
  category 'architecture', 'Architecture' do
    article 'architecture', 'Architecture'
  end
  category 'getting-started', 'Getting Started' do
    article 'quickstart', 'Getting Started with Fluentd'
  end
  category 'installation', 'Installation' do
    article 'before-install', 'Before Installing Fluentd'
    article 'install-by-rpm', 'Installing Fluentd using RPM Package (Redhat Linux)'
    article 'install-by-deb', 'Installing Fluentd using DEB Package (Debian / Ubuntu Linux)'
    article 'install-by-gem', 'Installing Fluentd using Ruby Gem'
    article 'install-by-chef', 'Installing Fluentd using Chef'
    article 'install-by-homebrew', 'Installing Fluentd using Homebrew (MacOS X)'
    article 'install-from-source', 'Installing Fluentd from Source'
    article 'install-on-heroku', 'Installing Fluentd on Heroku'
    article 'install-on-beanstalk', 'Installing Fluentd on AWS Elastic Beanstalk'
  end
  category 'users', 'Users' do
    article 'users', 'Users'
  end
  category 'datasheet', 'Data Sheet' do
    article 'datasheet', 'Data Sheet'
  end
  category 'slides', 'Slides' do
    article 'slides', 'Slides'
  end
  category 'support', 'Support' do
    article 'support', 'Support'
  end
  category 'faq', 'FAQ' do
    article 'faq', 'FAQ'
  end
end
section 'usecases', 'Use Cases' do
  category 'logging-from-apps', 'Centralized App Logging' do
    article 'ruby',   'Import Logs from Ruby Applications'
    article 'python', 'Import Logs from Python Applications'
    article 'php',    'Import Logs from PHP Applications'
    article 'perl',   'Import Logs from Perl Applications'
    article 'nodejs', 'Import Logs from Node.js Applications'
    article 'java',   'Import Logs from Java Applications'
    article 'scala',   'Import Logs from Scala Applications'
  end
  category 'free-alternative-to-splunk-by-fluentd', 'Log Management & Search' do
    article 'free-alternative-to-splunk-by-fluentd', 'Log Data Search', ['Splunk', 'Free Alternative']
  end
  category 'log-filtering-and-alerting', 'Log Filtering and Alerting' do
    article 'filter-modify-apache', 'Filter and Modify Data (Apache example)'
    article 'splunk-like-grep-and-alert-email', 'Email Alerts like Splunk', ['Splunk', 'Alerting']
  end
  category 'http-to-td', 'Big Data Analytics' do
    article 'http-to-td', 'Data Analytics with Treasure Data', ['Treasure Data', 'Hadoop', 'Hive']
  end
  category 'apache-to-s3', 'Data Archiving to S3' do
    article 'apache-to-s3', 'Store Apache Logs into Amazon S3', ['Amazon S3']
  end
  category 'apache-to-mongo', 'Data Collection to Mongo' do
    article 'apache-to-mongodb', 'Store Apache Logs into MongoDB', ['MongoDB']
  end
  category 'http-to-hdfs', 'Data Collection to HDFS' do
    article 'http-to-hdfs', 'Data Collection to HDFS', ['Hadoop', 'HDFS']
  end
  category 'apache-to-riak', 'Data Collection to Riak' do
    article 'apache-to-riak', 'Store Apache Logs into Riak', ['Riak']
  end
  category 'windows', 'Windows Event Collection' do
    article 'windows', 'Windows Event Collection'
  end
  category 'cloud-data-logger', 'RapsberryPi Data Logger' do
    article 'raspberrypi-cloud-data-logger', 'Raspberry Pi Cloud Data Logger', ['Raspberry Pi', 'Data Logger', 'Data Acquisition']
  end
end
section 'configuration', 'Configuration' do
  category 'config-file', 'Config File' do
    article 'config-file', 'Config File'
  end
  category 'recipes', 'Recipes' do
    for recipe in Dir.entries("#{settings.root}/docs").grep(/^recipe-/)
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
  category 'high-availability', 'High Availability Config' do
    article 'high-availability', 'Fluentd High Availability Configuration'
  end
  category 'failure-scenarios', 'Failure Scenarios' do
    article 'failure-scenarios', 'Failure Scenarios'
  end
  category 'performance-tuning', 'Performance Tuning' do
    article 'performance-tuning', 'Performance Tuning'
  end
  category 'trouble-shooting', 'Trouble Shooting' do
    article 'trouble-shooting', 'Trouble Shooting'
  end
end
section 'plugin', 'Input Plugins' do
  category 'input-plugin-overview', 'Overview' do
    article 'input-plugin-overview', 'Input Plugin Overview'
  end
  category 'in_forward', 'in_forward' do
    article 'in_forward', 'forward Input Plugin'
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
  category 'out_mongo', 'out_mongo' do
    article 'out_mongo', 'MongoDB Output Plugin', ['MongoDB']
  end
  category 'out_mongo_replset', 'out_mongo_replset' do
    article 'out_mongo_replset', 'MongoDB ReplicaSet Output Plugin', ['MongoDB', 'Mongo']
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
section 'developer', 'Developer' do
  category 'plugin-development', 'Plugin Development' do
    article 'plugin-development', 'Plugin Development'
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
section 'advanced-resources', 'Advanced Resources' do
  category 'whitepapers', 'Fluentd Best Practices for Advertising Business' do
    article 'adtech-best-practices', 'Adtech Fluentd Best Practices'
  end
end
