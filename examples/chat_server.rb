#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/net_server'

module ChatServer
  # Custom protocol for chat server
  class ChatProtocol < NetServer::Protocol
    def initialize(logger, broadcast_callback)
      super(logger)
      @broadcast_callback = broadcast_callback
      @usernames = {}
    end

    def handle_message(message, connection)
      case message.type
      when 'join'
        handle_join(message, connection)
      when 'chat'
        handle_chat(message, connection)
      when 'leave'
        handle_leave(message, connection)
      else
        super
      end
    end

    private

    def handle_join(message, connection)
      username = message.payload
      @usernames[connection.id] = username
      @logger.info("User #{username} joined (connection #{connection.id})")

      # Send welcome message
      welcome = NetServer::Message.new(
        type: 'system',
        payload: "Welcome to the chat, #{username}!",
        client_id: connection.id
      )
      connection.send_message(welcome)

      # Broadcast to all
      broadcast_message = "#{username} has joined the chat"
      @broadcast_callback.call(broadcast_message, exclude: connection.id)
    end

    def handle_chat(message, connection)
      username = @usernames[connection.id] || "User#{connection.id}"
      chat_message = "#{username}: #{message.payload}"
      @logger.info("Chat message: #{chat_message}")

      # Broadcast to all clients
      @broadcast_callback.call(chat_message)
    end

    def handle_leave(message, connection)
      username = @usernames.delete(connection.id) || "User#{connection.id}"
      @logger.info("User #{username} left")

      # Broadcast to all
      leave_message = "#{username} has left the chat"
      @broadcast_callback.call(leave_message, exclude: connection.id)

      connection.close
    end
  end

  # Custom chat server
  class Server < NetServer::Server
    def initialize(config = NetServer::Configuration.new, logger: NetServer::Logger.new)
      super
      @protocol = ChatProtocol.new(@logger, method(:broadcast))
    end

    def broadcast(message, exclude: nil)
      # Note: This method is called from within process_connections
      # which already holds the mutex, so we don't lock here
      @connections.each do |id, connection|
        next if id == exclude
        next if connection.closed?

        msg = NetServer::Message.new(
          type: 'broadcast',
          payload: message,
          client_id: id
        )
        connection.send_message(msg)
      end
    end
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  port = ARGV[0]&.to_i || 9091
  host = ARGV[1] || 'localhost'

  config = NetServer::Configuration.new(
    host: host,
    port: port,
    max_connections: 20
  )

  logger = NetServer::Logger.new($stdout, level: :info)
  server = ChatServer::Server.new(config, logger: logger)

  trap('INT') do
    puts "\nShutting down chat server..."
    server.stop
    exit(0)
  end

  trap('TERM') do
    puts "\nShutting down chat server..."
    server.stop
    exit(0)
  end

  puts "Starting chat server on #{host}:#{port}"
  server.start
end
