#!/usr/bin/env ruby

require 'erb'

DOCS_DIR = File.expand_path('../../docs', __FILE__)
CONF_DIR = File.expand_path('../conf', __FILE__)
CANONICAL_TO_PLUGIN_NAME = {
  "csv" => "tail",
  "json" => "tail",
  "tsv" => "tail",
  "apache logs" => "tail",
  "nginx" => "tail",
  "treasure data" => "td",
  "http rest api" => "http",
}

def default_plugin?(name)
  /^(?:tail|syslog|file|http|forward)$/.match(name) 
end

def help
  puts "#{__FILE__} <input> <output>"
  exit(0)
end

def generate_conf(input_conf, output_conf)
  input_conf = input_conf.split("\n").map { |l| "    "+l }.join("\n")
  output_conf = output_conf.split("\n").map { |l| "    "+l }.join("\n")
  [input_conf, output_conf].join("\n    \n")
end

def generate_recipe!(input, output)
  input_conf = File.new([CONF_DIR, "input/#{input}.conf"].join("/")).read
  output_conf = File.new([CONF_DIR, "output/#{output}.conf"].join("/")).read
  example_conf = generate_conf(input_conf, output_conf)
  input_plugin = CANONICAL_TO_PLUGIN_NAME[input] || input
  input_plugin = nil if default_plugin?(input_plugin)
  output_plugin = CANONICAL_TO_PLUGIN_NAME[output] || output
  output_plugin = nil if default_plugin?(output_plugin)
  erb_res = ERB.new(File.new([CONF_DIR, 'template.erb'].join("/")).read, 0, "-").result(binding)
  doc_filepath = [DOCS_DIR, "recipe-#{input.gsub(" ", "-")}-to-#{output.gsub(" ", "-")}.txt"].join("/")
  File.open(doc_filepath, 'w') { |f| f.write(erb_res) }
end


if ARGV.length == 2
  input, output = ARGV
  generate_recipe!(input, output)  
elsif ARGV.length == 1 && ARGV[0] == 'all'
  inputs = Dir.entries("#{CONF_DIR}/input/").grep(/.*\.conf$/).map {|f| f.chomp(".conf")}
  outputs = Dir.entries("#{CONF_DIR}/output/").grep(/.*\.conf$/).map {|f| f.chomp(".conf")}
  for input in inputs
    for output in outputs
      generate_recipe!(input, output)
    end
  end
else
  help unless ARGV.length == 2 or (ARGV.length == 1 and ARGV[0] == 'all')
end
