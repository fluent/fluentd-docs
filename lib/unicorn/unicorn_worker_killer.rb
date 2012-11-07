
module UnicornWorkerKiller
  def self.kill_self(logger, start_time)
    alive_sec = (Time.now - start_time).to_i

    i = 0
    while true
      i += 1
      sig = :TERM
      if i > 10     # TODO configurable TERM MAX
        sig = :QUIT
      elsif i > 15  # TODO configurable QUIT MAX
        sig = :KILL
      end

      logger.warn "#{self} send SIGTERM (pid: #{Process.pid})\talive: #{alive_sec} sec (trial #{i})"
      Process.kill sig, Process.pid

      sleep 1  # TODO configurable sleep
    end
  end

  module Oom
    def self.new(app, memory_size = 512 * 1024, check_cycle = 16)
      ObjectSpace.each_object(Unicorn::HttpServer) do |s|
        s.extend(self)
        s.instance_variable_set(:@_wk_memory_size, memory_size)
        s.instance_variable_set(:@_wk_check_cycle, check_cycle)
        s.instance_variable_set(:@_wk_check_count, 0)
      end
      app # pretend to be Rack middleware since it was in the past
    end

    def process_client(client)
      @_wk_process_start ||= Time.now
      super(client) # Unicorn::HttpServer#process_client

      c = @_wk_check_count + 1
      if c % @_wk_check_cycle == 0
        @_wk_check_count = 0
        if _wk_rss > @_wk_memory_size
          UnicornWorkerKiller.kill_self(logger, @_wk_process_start)
        end
      else
        @_wk_check_count = c
      end
    end

    private
    def _wk_rss
      proc_status = "/proc/#{Process.pid}/status"
      if File.exists? proc_status
        open(proc_status).each_line { |l|
          if l.include? 'VmRSS'
            ls = l.split
            if ls.length == 3
              value = ls[1].to_i
              unit = ls[2]
              case unit.downcase
              when 'kb'
                return value*(1)
              when 'mb'
                return value*(1024**1)
              when 'gb'
                return value*(1024**2)
              end
            end
          end
        }
      end
      return `ps -o rss= -p #{Process.pid}`.to_i
    end
  end

  module MaxRequests
    def self.new(app, max_requests = 1000)
      ObjectSpace.each_object(Unicorn::HttpServer) do |s|
        s.extend(self)
        s.instance_variable_set(:@_wk_max_requests, max_requests)
      end
      app # pretend to be Rack middleware since it was in the past
    end

    def process_client(client)
      @_wk_process_start ||= Time.now
      super(client) # Unicorn::HttpServer#process_client

      if (@_wk_max_requests -= 1) <= 0
        UnicornWorkerKiller.kill_self(logger, @_wk_process_start)
      end
    end
  end
end

