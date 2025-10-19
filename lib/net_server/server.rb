# frozen_string_literal: true

require 'socket'
require_relative 'configuration'
require_relative 'connection'
require_relative 'protocol'
require_relative 'message'
require_relative 'logger'

module NetServer
  # Server class for handling TCP server operations
  class Server
    attr_reader :config, :logger, :connections

    def initialize(config = Configuration.new, logger: Logger.new)
      @config = config
      @logger = logger
      @connections = {}
      @running = false
      @server_socket = nil
      @protocol = Protocol.new(@logger)
      @next_connection_id = 1
      @mutex = Mutex.new
    end

    def start
      @config.validate!
      @logger.info("Starting server on #{@config}")

      @server_socket = TCPServer.new(@config.host, @config.port)
      @server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
      @running = true

      @logger.info("Server started successfully on #{@config.host}:#{@config.port}")

      accept_loop
    rescue StandardError => e
      @logger.fatal("Failed to start server: #{e.message}")
      @logger.fatal(e.backtrace.join("\n"))
      stop
      raise
    end

    def stop
      @logger.info('Stopping server...')
      @running = false

      # Close all connections
      @mutex.synchronize do
        @connections.each_value(&:close)
        @connections.clear
      end

      # Close server socket
      @server_socket&.close unless @server_socket&.closed?
      @logger.info('Server stopped')
    end

    def running?
      @running
    end

    private

    def accept_loop
      while @running
        begin
          # Use select with timeout to check for incoming connections
          readable, = IO.select([@server_socket], nil, nil, 1)
          next unless readable

          client_socket = @server_socket.accept_nonblock
          handle_new_connection(client_socket)
        rescue IO::WaitReadable, Errno::EINTR
          # No connection ready, continue loop
          next
        rescue StandardError => e
          @logger.error("Error accepting connection: #{e.message}")
        end

        # Process existing connections
        process_connections
      end
    end

    def handle_new_connection(client_socket)
      @mutex.synchronize do
        if @connections.size >= @config.max_connections
          @logger.warn('Max connections reached, rejecting new connection')
          client_socket.close
          return
        end

        connection_id = @next_connection_id
        @next_connection_id += 1

        connection = Connection.new(client_socket, connection_id, @logger)
        @connections[connection_id] = connection
        @logger.info("New connection accepted: #{connection}")
      end
    end

    def process_connections
      @mutex.synchronize do
        @connections.each do |id, connection|
          next if connection.closed?

          begin
            data = connection.receive(@config.buffer_size)
            next unless data

            message = Message.parse(data)
            @protocol.handle_message(message, connection)
          rescue StandardError => e
            @logger.error("Error processing connection #{id}: #{e.message}")
            connection.close
          end
        end

        # Remove closed connections
        @connections.delete_if { |_, conn| conn.closed? }
      end
    end
  end
end
