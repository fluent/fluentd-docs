# -*- coding: utf-8 -*-

section 'overview', 'Overview' do
  category 'getting-started', 'はじめよう' do
    article 'quickstart', 'クイックスタートガイド'
  end
  category 'architecture', 'アーキテクチャ' do
    article 'architecture', 'アーキテクチャ'
  end
  category 'installation', 'インストール' do
    article 'before-install', 'Fluentdインストールの前に'
    article 'install-by-homebrew', 'HomebrewでFluentdをインストールする (Mac OS X)'
    article 'install-by-rpm', 'RPMパッケージからFluentdをインストールする (Redhat Linux)'
    article 'install-by-deb', 'DEBパッケージからFluentdをインストールする (Debian / Ubuntu Linux)'
    article 'install-by-gem', 'Ruby GemからFluentdをインストールする'
    article 'install-by-chef', 'ChefでFluentdをインストールする'
    article 'install-from-source', 'ソースコードからFluentdをインストールする'
    article 'install-on-heroku', 'Heroku上にFluentd (td-agent)をインストールする'
    article 'install-on-beanstalk', 'AWS Elastic Beanstalk上にFluentd (td-agent)をインストールする'
  end
  category 'users', 'ユーザー' do
    article 'users', 'Fluentdのユーザー'
  end
  category 'slides', 'スライド' do
    article 'slides', 'スライド'
  end
  category 'support', 'サポート' do
    article 'support', 'サポート'
  end
  category 'faq', 'FAQ' do
    article 'faq', 'FAQ'
  end
end
section 'tutorial', 'Tutorial' do
  category 'free-alternative-to-splunk-by-fluentd', 'Data Search like Splunk' do
    article 'free-alternative-to-splunk-by-fluentd', 'Data Search like Splunk', ['Splunk', 'Free Alternative']
  end
  category 'http-to-td', 'Data Analytics with TD' do
    article 'http-to-td', 'Data Analytics with Treasure Data', ['Treasure Data', 'Hadoop', 'Hive']
  end
  category 'apache-to-mongo', 'Data Collection to Mongo' do
    article 'apache-to-mongodb', 'Store Apache Logs into MongoDB', ['MongoDB']
  end
  category 'http-to-hdfs', 'Data Collection to HDFS' do
    article 'http-to-hdfs', 'Data Collection to HDFS', ['Hadoop', 'HDFS']
  end
  category 'apache-to-s3', 'Data Archiving to S3' do
    article 'apache-to-s3', 'Store Apache Logs into Amazon S3', ['Amazon S3']
  end
  category 'ruby', 'Logging from Ruby' do
    article 'ruby',   'Import Logs from Ruby Applications'
  end
  category 'python', 'Logging from Python' do
    article 'python', 'Import Logs from Python Applications'
  end
  category 'php', 'Logging from PHP' do
    article 'php',    'Import Logs from PHP Applications'
  end
  category 'perl', 'Logging from Perl' do
    article 'perl',   'Import Logs from Perl Applications'
  end
  category 'nodejs', 'Logging from Node.js' do
    article 'nodejs', 'Import Logs from Node.js Applications'
  end
  category 'java', 'Logging from Java' do
    article 'java',   'Import Logs from Java Applications'
  end
  category 'scala', 'Logging from Scala' do
    article 'scala',   'Import Logs from Scala Applications'
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
  category 'high-availability', 'High Availability' do
    article 'high-availability', 'Fluentd High Availability Configuration'
  end
  category 'failure-scenarios', '障害のシナリオ' do
    article 'failure-scenarios', '障害のシナリオ'
  end
  category 'monitoring', '監視' do
    article 'monitoring', '監視'
  end
  category 'signals', 'シグナル一覧' do
    article 'signals', 'シグナル処理', ['シグナル一覧']
  end
  category 'trouble-shooting', 'トラブルシューティング' do
    article 'trouble-shooting', 'トラブルシューティング'
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
  category 'in_others', 'Others' do
    article 'in_others', 'Ohter Input Plugins'
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
