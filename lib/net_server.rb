# frozen_string_literal: true

# NetServer - A Ruby networking library for TCP socket communication
module NetServer
  VERSION = '1.0.0'
end

require_relative 'net_server/logger'
require_relative 'net_server/configuration'
require_relative 'net_server/message'
require_relative 'net_server/connection'
require_relative 'net_server/protocol'
require_relative 'net_server/server'
require_relative 'net_server/client'
