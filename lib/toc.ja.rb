# -*- coding: utf-8 -*-

section 'overview', 'Overview' do
  category 'getting-started', 'はじめよう' do
    article 'quickstart', 'クイックスタートガイド'
  end
  category 'installation', 'インストール' do
    article 'before-install', 'Fluentdインストールの前に'
    article 'install-by-rpm', 'RPMパッケージからFluentdをインストールする (Redhat Linux)'
    article 'install-by-deb', 'DEBパッケージからFluentdをインストールする (Debian / Ubuntu Linux)'
    article 'install-by-dmg', 'DMGパッケージからFluentdをインストールする (Mac OS X)'
    article 'install-by-gem', 'Ruby GemからFluentdをインストールする'
    article 'install-by-chef', 'ChefでFluentdをインストールする'
    article 'install-from-source', 'ソースコードからFluentdをインストールする'
    article 'install-on-heroku', 'Heroku上にFluentd (td-agent)をインストールする'
    article 'install-on-beanstalk', 'AWS Elastic Beanstalk上にFluentd (td-agent)をインストールする'
  end
  category 'support', 'サポート' do
    article 'support', 'サポート'
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
  category 'splunk-like-grep-and-alert-email', 'Log Filtering and Alerting' do
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
  category 'config-file', '設定ファイル' do
    article 'config-file', '設定ファイル'
  end
  category 'recipes', 'Recipes' do
    for recipe in Dir.entries("#{settings.root}/docs/ja").grep(/^recipe-/)
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
  category 'logging', 'ロギング' do
    article 'logging', 'ロギング'
  end
  category 'monitoring', '監視' do
    article 'monitoring', '監視'
  end
  category 'signals', 'シグナル一覧' do
    article 'signals', 'シグナル処理', ['シグナル一覧']
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
  category 'trouble-shooting', 'トラブルシューティング' do
    article 'trouble-shooting', 'トラブルシューティング'
  end
end
section 'plugin', 'Input Plugins' do
  category 'input-plugin-overview', '概要' do
    article 'input-plugin-overview', 'Inputプラグインの概要'
  end
  category 'in_forward', 'in_forward' do
    article 'in_forward', 'forward Inputプラグイン'
  end
  category 'in_secure_forward', 'in_secure_forward' do
    article 'in_secure_forward', 'secure_forward Intput Plugin', ['SSL', 'authentication']
  end
  category 'in_http', 'in_http' do
    article 'in_http', 'http Inputプラグイン'
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
  category 'in_others', 'その他' do
    article 'in_others', 'その他のinputプラグイン'
  end
end
section 'output-plugins', 'Output Plugins' do
  category 'output-plugin-overview', '概要' do
    article 'output-plugin-overview', 'アウトプットプラグイン概要'
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
  category 'buffer-plugin-overview', '概要' do
    article 'buffer-plugin-overview', 'Bufferプラグインの概要'
  end
  category 'buf_memory', 'buf_memory' do
    article 'buf_memory', 'memory Bufferプラグイン'
  end
  category 'buf_file', 'buf_file' do
    article 'buf_file', 'file Bufferプラグイン'
  end
end
section 'developer', 'Developer' do
  category 'plugin-development', 'Plugin Development' do
    article 'plugin-development', 'Plugin Development'
  end
  category 'community', 'Community' do
    article 'community', 'Community'
  end
  category 'mailing-list', 'メーリングリスト' do
    article 'mailing-list', 'メーリングリスト'
  end
  category 'source-code', 'ソースコード' do
    article 'source-code', 'ソースコード'
  end
  category 'bug-tracking', 'バグ管理' do
    article 'bug-tracking', 'バグ管理'
  end
  category 'changelog', '変更履歴' do
    article 'changelog', '変更履歴'
  end
  category 'logo', 'ロゴ' do
    article 'logo', 'ロゴ'
  end
end
