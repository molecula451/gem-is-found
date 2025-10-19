# frozen_string_literal: true

require_relative 'message'

module NetServer
  # Protocol class for handling message protocols
  class Protocol
    def initialize(logger)
      @logger = logger
    end

    def handle_message(message, connection)
      @logger.debug("Handling message: #{message.type}")

      case message.type
      when 'ping'
        handle_ping(message, connection)
      when 'echo'
        handle_echo(message, connection)
      when 'text'
        handle_text(message, connection)
      when 'disconnect'
        handle_disconnect(message, connection)
      else
        handle_unknown(message, connection)
      end
    end

    private

    def handle_ping(message, connection)
      @logger.info("Ping received from #{connection.id}")
      response = Message.new(type: 'pong', payload: 'pong', client_id: connection.id)
      connection.send_message(response)
    end

    def handle_echo(message, connection)
      @logger.info("Echo request from #{connection.id}: #{message.payload}")
      response = Message.new(type: 'echo_response', payload: message.payload, client_id: connection.id)
      connection.send_message(response)
    end

    def handle_text(message, connection)
      @logger.info("Text message from #{connection.id}: #{message.payload}")
      response = Message.new(
        type: 'text_response',
        payload: "Received: #{message.payload}",
        client_id: connection.id
      )
      connection.send_message(response)
    end

    def handle_disconnect(message, connection)
      @logger.info("Disconnect request from #{connection.id}")
      response = Message.new(type: 'disconnect_ack', payload: 'Goodbye', client_id: connection.id)
      connection.send_message(response)
      connection.close
    end

    def handle_unknown(message, connection)
      @logger.warn("Unknown message type '#{message.type}' from #{connection.id}")
      response = Message.new(
        type: 'error',
        payload: "Unknown message type: #{message.type}",
        client_id: connection.id
      )
      connection.send_message(response)
    end
  end
end
