# frozen_string_literal: true

module NetServer
  # Configuration class for server settings
  class Configuration
    attr_accessor :host, :port, :max_connections, :timeout, :buffer_size

    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = 9090
    DEFAULT_MAX_CONNECTIONS = 10
    DEFAULT_TIMEOUT = 30
    DEFAULT_BUFFER_SIZE = 1024

    def initialize(options = {})
      @host = options.fetch(:host, DEFAULT_HOST)
      @port = options.fetch(:port, DEFAULT_PORT)
      @max_connections = options.fetch(:max_connections, DEFAULT_MAX_CONNECTIONS)
      @timeout = options.fetch(:timeout, DEFAULT_TIMEOUT)
      @buffer_size = options.fetch(:buffer_size, DEFAULT_BUFFER_SIZE)
    end

    def to_s
      "#{@host}:#{@port} (max_connections: #{@max_connections}, " \
        "timeout: #{@timeout}s, buffer: #{@buffer_size} bytes)"
    end

    def validate!
      raise ArgumentError, 'Host cannot be empty' if @host.nil? || @host.empty?
      raise ArgumentError, 'Port must be between 1 and 65535' unless @port.between?(1, 65535)
      raise ArgumentError, 'Max connections must be positive' unless @max_connections.positive?
      raise ArgumentError, 'Timeout must be positive' unless @timeout.positive?
      raise ArgumentError, 'Buffer size must be positive' unless @buffer_size.positive?

      true
    end
  end
end
