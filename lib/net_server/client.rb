# frozen_string_literal: true

require 'socket'
require_relative 'message'
require_relative 'logger'

module NetServer
  # Client class for handling TCP client connections
  class Client
    attr_reader :host, :port, :logger

    def initialize(host = 'localhost', port = 9090, logger: Logger.new)
      @host = host
      @port = port
      @logger = logger
      @socket = nil
      @connected = false
    end

    def connect
      @logger.info("Connecting to #{@host}:#{@port}...")
      @socket = TCPSocket.new(@host, @port)
      @connected = true
      @logger.info("Connected to #{@host}:#{@port}")
      true
    rescue StandardError => e
      @logger.error("Failed to connect: #{e.message}")
      @connected = false
      false
    end

    def disconnect
      return unless connected?

      @logger.info('Disconnecting...')
      @socket&.close unless @socket&.closed?
      @connected = false
      @logger.info('Disconnected')
    end

    def connected?
      @connected && @socket && !@socket.closed?
    end

    def send_message(message)
      raise 'Not connected' unless connected?

      data = message.to_json + "\n"
      @socket.write(data)
      @socket.flush
      @logger.debug("Sent message: #{message.type}")
      true
    rescue StandardError => e
      @logger.error("Error sending message: #{e.message}")
      disconnect
      false
    end

    def send_text(text)
      message = Message.new(type: 'text', payload: text)
      send_message(message)
    end

    def send_ping
      message = Message.new(type: 'ping', payload: 'ping')
      send_message(message)
    end

    def send_echo(text)
      message = Message.new(type: 'echo', payload: text)
      send_message(message)
    end

    def receive(timeout: 5)
      raise 'Not connected' unless connected?

      readable, = IO.select([@socket], nil, nil, timeout)
      return nil unless readable

      data = @socket.recv_nonblock(1024)
      return nil if data.empty?

      @logger.debug("Received: #{data.bytesize} bytes")
      Message.from_json(data.strip)
    rescue IO::WaitReadable
      nil
    rescue EOFError, Errno::ECONNRESET => e
      @logger.warn("Connection closed by server: #{e.message}")
      disconnect
      nil
    rescue StandardError => e
      @logger.error("Error receiving data: #{e.message}")
      nil
    end

    def ping_server
      return false unless send_ping

      response = receive(timeout: 3)
      response&.type == 'pong'
    end

    def echo_test(text)
      return nil unless send_echo(text)

      sleep 0.1  # Small delay to allow server to process
      response = receive(timeout: 3)
      response&.payload
    end
  end
end
