# frozen_string_literal: true

require 'time'

module NetServer
  # Logger class for handling application logging
  class Logger
    LEVELS = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
      fatal: 4
    }.freeze

    attr_accessor :level
    attr_reader :output

    def initialize(output = $stdout, level: :info)
      @output = output
      @level = level
      @mutex = Mutex.new
    end

    def debug(message)
      log(:debug, message)
    end

    def info(message)
      log(:info, message)
    end

    def warn(message)
      log(:warn, message)
    end

    def error(message)
      log(:error, message)
    end

    def fatal(message)
      log(:fatal, message)
    end

    private

    def log(level, message)
      return unless should_log?(level)

      @mutex.synchronize do
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        formatted_message = "[#{timestamp}] #{level.to_s.upcase}: #{message}"
        @output.puts(formatted_message)
        @output.flush
      end
    end

    def should_log?(level)
      LEVELS[level] >= LEVELS[@level]
    end
  end
end
