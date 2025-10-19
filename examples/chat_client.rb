#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/net_server'
require 'io/console'

module ChatClient
  # Chat client with threaded message receiving
  class Client < NetServer::Client
    attr_reader :username

    def initialize(host, port, username, logger: NetServer::Logger.new)
      super(host, port, logger: logger)
      @username = username
      @receiving = false
      @receiver_thread = nil
    end

    def join_chat
      return false unless connected?

      join_message = NetServer::Message.new(type: 'join', payload: @username)
      send_message(join_message)
    end

    def send_chat_message(text)
      return false unless connected?

      chat_message = NetServer::Message.new(type: 'chat', payload: text)
      send_message(chat_message)
    end

    def leave_chat
      return false unless connected?

      leave_message = NetServer::Message.new(type: 'leave', payload: @username)
      send_message(leave_message)
    end

    def start_receiving
      @receiving = true
      @receiver_thread = Thread.new do
        receive_loop
      end
    end

    def stop_receiving
      @receiving = false
      @receiver_thread&.join
    end

    private

    def receive_loop
      while @receiving && connected?
        begin
          message = receive(timeout: 1)
          next unless message

          case message.type
          when 'system', 'broadcast'
            puts "\r\e[K#{message.payload}"
            print '> '
            $stdout.flush
          end
        rescue StandardError => e
          @logger.error("Receive error: #{e.message}")
          break
        end
      end
    end
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  host = ARGV[0] || 'localhost'
  port = ARGV[1]&.to_i || 9091

  print 'Enter your username: '
  username = gets.chomp

  if username.empty?
    puts 'Username cannot be empty'
    exit(1)
  end

  logger = NetServer::Logger.new($stdout, level: :warn)
  client = ChatClient::Client.new(host, port, username, logger: logger)

  unless client.connect
    puts 'Failed to connect to chat server'
    exit(1)
  end

  unless client.join_chat
    puts 'Failed to join chat'
    exit(1)
  end

  puts "\nConnected to chat server at #{host}:#{port}"
  puts 'Type messages to chat (or "quit" to exit):'
  puts

  client.start_receiving

  loop do
    print '> '
    input = gets&.chomp
    break unless input

    case input
    when 'quit', 'exit', '/quit'
      client.leave_chat
      break
    when ''
      next
    else
      unless client.send_chat_message(input)
        puts 'Failed to send message'
        break
      end
    end
  end

  client.stop_receiving
  client.disconnect
  puts "\nDisconnected from chat server"
end
