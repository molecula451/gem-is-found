# frozen_string_literal: true

require 'socket'
require_relative 'message'

module NetServer
  # Connection class for handling individual client connections
  class Connection
    attr_reader :socket, :id, :remote_address, :remote_port

    def initialize(socket, id, logger)
      @socket = socket
      @id = id
      @logger = logger
      @remote_address = socket.peeraddr[3]
      @remote_port = socket.peeraddr[1]
      @closed = false
      @logger.info("Connection #{@id} established from #{@remote_address}:#{@remote_port}")
    end

    def receive(buffer_size = 1024)
      return nil if closed?

      data = @socket.recv_nonblock(buffer_size)
      return nil if data.empty?

      @logger.debug("Connection #{@id} received: #{data.bytesize} bytes")
      data
    rescue IO::WaitReadable
      nil
    rescue EOFError, Errno::ECONNRESET => e
      @logger.warn("Connection #{@id} closed by peer: #{e.message}")
      close
      nil
    end

    def send_data(data)
      return false if closed?

      @socket.write(data)
      @socket.flush
      @logger.debug("Connection #{@id} sent: #{data.bytesize} bytes")
      true
    rescue Errno::EPIPE, Errno::ECONNRESET => e
      @logger.error("Connection #{@id} error sending data: #{e.message}")
      close
      false
    end

    def send_message(message)
      send_data(message.to_json + "\n")
    end

    def close
      return if closed?

      @socket.close unless @socket.closed?
      @closed = true
      @logger.info("Connection #{@id} closed")
    rescue StandardError => e
      @logger.error("Error closing connection #{@id}: #{e.message}")
    end

    def closed?
      @closed || @socket.closed?
    end

    def to_s
      "Connection #{@id} (#{@remote_address}:#{@remote_port})"
    end
  end
end
