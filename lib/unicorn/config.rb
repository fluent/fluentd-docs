# What the timeout for killing busy workers is, in seconds
timeout 60

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes 4

# before/after forks
before_fork do |server, worker|
  sleep 1
end
after_fork do |server, worker|
  GC.disable
end
