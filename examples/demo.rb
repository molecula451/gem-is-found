#!/usr/bin/env ruby
# frozen_string_literal: true

# Demo script showing the networking capabilities
# This script demonstrates the various features of the NetServer library

require_relative '../lib/net_server'

puts "=" * 70
puts "NetServer Ruby Networking Library Demo"
puts "=" * 70
puts

puts "This library demonstrates Ruby networking with:"
puts "  • TCP socket programming"
puts "  • Localhost communication"
puts "  • Port-based networking"
puts "  • Class-based architecture"
puts "  • Multiple concurrent connections"
puts

puts "Classes implemented:"
puts "  1. NetServer::Server - TCP server with non-blocking I/O"
puts "  2. NetServer::Client - TCP client for server communication"
puts "  3. NetServer::Connection - Individual connection handler"
puts "  4. NetServer::Protocol - Message protocol handler"
puts "  5. NetServer::Message - JSON-based message structure"
puts "  6. NetServer::Configuration - Server configuration"
puts "  7. NetServer::Logger - Multi-level logging system"
puts

puts "Files in the project:"
puts "  • lib/net_server/*.rb - 7 core class files"
puts "  • lib/net_server.rb - Main module file"
puts "  • examples/chat_server.rb - Multi-client chat server"
puts "  • examples/chat_client.rb - Interactive chat client"
puts "  Total: 10 Ruby files"
puts

puts "=" * 70
puts "Quick Start Examples:"
puts "=" * 70
puts

puts "1. Start a basic echo server:"
puts "   $ ruby bin/server 9090"
puts

puts "2. Connect with a client:"
puts "   $ ruby bin/client localhost 9090"
puts "   > ping"
puts "   > echo Hello World"
puts "   > quit"
puts

puts "3. Start a chat server:"
puts "   $ ruby examples/chat_server.rb 9091"
puts

puts "4. Connect multiple chat clients:"
puts "   $ ruby examples/chat_client.rb localhost 9091"
puts "   Enter your username: Alice"
puts "   > Hello everyone!"
puts

puts "=" * 70
puts "Networking Concepts Demonstrated:"
puts "=" * 70
puts

puts "Socket Programming:"
puts "  • TCPServer.new(host, port) - Create server socket"
puts "  • TCPSocket.new(host, port) - Create client socket"
puts "  • IO.select() - Non-blocking I/O multiplexing"
puts "  • Socket options (SO_REUSEADDR)"
puts

puts "Connection Management:"
puts "  • Accept incoming connections"
puts "  • Track multiple concurrent clients"
puts "  • Graceful disconnect handling"
puts "  • Automatic cleanup"
puts

puts "Protocol Design:"
puts "  • JSON-based message format"
puts "  • Multiple message types (ping, echo, text, chat, etc.)"
puts "  • Request-response patterns"
puts "  • Broadcast messaging"
puts

puts "Thread Safety:"
puts "  • Mutex for shared state protection"
puts "  • Thread-safe connection management"
puts "  • Concurrent client handling"
puts

puts "=" * 70
puts "Example Message Format:"
puts "=" * 70
puts

example_message = NetServer::Message.new(
  type: 'echo',
  payload: 'Hello World',
  client_id: 1
)

puts "Message object:"
puts "  type: #{example_message.type}"
puts "  payload: #{example_message.payload}"
puts "  timestamp: #{example_message.timestamp}"
puts

puts "JSON representation:"
puts "  #{example_message.to_json}"
puts

puts "=" * 70
puts "Configuration Example:"
puts "=" * 70
puts

config = NetServer::Configuration.new(
  host: 'localhost',
  port: 9090,
  max_connections: 10,
  timeout: 30,
  buffer_size: 1024
)

puts "Server configuration:"
puts "  #{config}"
puts

puts "=" * 70
puts "For more information, see README.md"
puts "=" * 70
