# gem-is-found

A Ruby networking library demonstrating TCP socket communication, localhost connectivity, and port-based networking with comprehensive class-based architecture.

## Overview

This project implements a complete networking framework in Ruby with the following components:

- **TCP Server/Client Architecture**: Full-featured server and client implementations
- **Socket-based Communication**: Direct socket programming using Ruby's Socket library
- **Localhost Networking**: All examples use localhost for secure local development
- **Port Management**: Configurable port settings for multiple concurrent servers
- **Message Protocol**: JSON-based message protocol with multiple message types
- **Connection Management**: Thread-safe connection handling with proper resource cleanup
- **Logging System**: Comprehensive logging at multiple levels
- **Chat Application**: Real-world example of multi-client communication

## Project Structure

```
.
├── lib/
│   ├── net_server.rb              # Main module file
│   └── net_server/
│       ├── server.rb              # TCP Server class
│       ├── client.rb              # TCP Client class
│       ├── connection.rb          # Connection handler class
│       ├── protocol.rb            # Message protocol handler
│       ├── message.rb             # Message class for network data
│       ├── configuration.rb       # Server configuration class
│       └── logger.rb              # Logging class
├── bin/
│   ├── server                     # Server executable
│   └── client                     # Client executable
└── examples/
    ├── chat_server.rb             # Chat server example
    └── chat_client.rb             # Chat client example
```

## Classes and Architecture

### Core Classes

1. **NetServer::Server** - Main TCP server class
   - Manages incoming connections on specified host:port
   - Handles multiple concurrent clients
   - Implements non-blocking I/O with select()
   - Thread-safe connection management

2. **NetServer::Client** - TCP client class
   - Connects to server via TCP socket
   - Sends and receives messages
   - Handles disconnection gracefully

3. **NetServer::Connection** - Individual connection handler
   - Wraps socket communication
   - Manages connection lifecycle
   - Tracks remote address and port

4. **NetServer::Protocol** - Message protocol handler
   - Processes different message types (ping, echo, text, disconnect)
   - Extensible for custom protocols
   - Handles unknown message types gracefully

5. **NetServer::Message** - Message data structure
   - JSON-based serialization
   - Type-safe message handling
   - Timestamp tracking

6. **NetServer::Configuration** - Server settings
   - Host and port configuration
   - Connection limits
   - Buffer sizes and timeouts
   - Validation logic

7. **NetServer::Logger** - Logging system
   - Multiple log levels (debug, info, warn, error, fatal)
   - Thread-safe logging
   - Timestamp formatting

## Usage

### Basic Server

Start a server on localhost:9090:

```bash
ruby bin/server 9090
```

Or specify a different host:

```bash
ruby bin/server 9090 0.0.0.0
```

### Basic Client

Connect to a server:

```bash
ruby bin/client localhost 9090
```

Once connected, you can:
- Send text messages (type any text)
- Ping the server (type `ping`)
- Echo messages (type `echo Hello World`)
- Exit (type `quit`)

### Chat Server Example

Start a chat server on port 9091:

```bash
ruby examples/chat_server.rb 9091
```

### Chat Client Example

Connect to the chat server:

```bash
ruby examples/chat_client.rb localhost 9091
```

Multiple clients can connect simultaneously and chat with each other!

## Networking Concepts Demonstrated

### 1. Socket Programming
- Creating TCP sockets using Ruby's Socket library
- Binding to localhost and ports
- Accepting incoming connections
- Non-blocking I/O operations

### 2. Client-Server Architecture
- Server listens on a port
- Clients connect to server
- Bidirectional communication
- Connection lifecycle management

### 3. Localhost Communication
- All servers bind to localhost by default
- Secure local development environment
- Can be configured for network access

### 4. Port Management
- Configurable port numbers
- Socket reuse (SO_REUSEADDR)
- Multiple servers on different ports
- Port validation (1-65535)

### 5. Protocol Design
- JSON-based message format
- Message types for different operations
- Request-response patterns
- Broadcast messaging (chat example)

### 6. Concurrency
- Multiple simultaneous connections
- Thread-safe connection management
- Non-blocking I/O with IO.select
- Mutex for shared state protection

## Example Sessions

### Echo Server Session

**Server:**
```
$ ruby bin/server 9090
[2024-01-01 12:00:00] INFO: Starting server on localhost:9090 (max_connections: 10, timeout: 30s, buffer: 1024 bytes)
[2024-01-01 12:00:00] INFO: Server started successfully on localhost:9090
[2024-01-01 12:00:05] INFO: Connection 1 established from 127.0.0.1:54321
[2024-01-01 12:00:10] INFO: Echo request from 1: Hello World
```

**Client:**
```
$ ruby bin/client localhost 9090
[2024-01-01 12:00:05] INFO: Connected to localhost:9090

Connected to server at localhost:9090
Type messages to send (or "quit" to exit):
Commands: ping, echo <text>, quit

> ping
Server responded with pong!
> echo Hello World
Server echoed: Hello World
> quit
```

## Technical Details

### Socket Operations
- **TCPServer.new(host, port)** - Creates server socket
- **TCPSocket.new(host, port)** - Creates client socket
- **IO.select()** - Non-blocking I/O multiplexing
- **socket.recv_nonblock()** - Non-blocking receive
- **socket.write()** - Send data

### Connection Handling
- Each connection gets a unique ID
- Remote address and port tracking
- Graceful disconnect handling
- Automatic cleanup of closed connections

### Message Format
Messages are JSON objects:
```json
{
  "type": "echo",
  "payload": "Hello World",
  "timestamp": 1234567890,
  "client_id": 1
}
```

## Requirements

- Ruby 3.2.3 or higher
- No external dependencies (uses only Ruby standard library)

## Development

The project uses only Ruby standard library components:
- `socket` - TCP socket operations
- `json` - Message serialization
- `time` - Timestamp handling
- `thread` - Mutex for thread safety

## License

MIT License