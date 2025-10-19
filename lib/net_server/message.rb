# frozen_string_literal: true

require 'json'

module NetServer
  # Message class for handling network messages
  class Message
    attr_reader :type, :payload, :timestamp, :client_id

    def initialize(type:, payload:, client_id: nil)
      @type = type
      @payload = payload
      @timestamp = Time.now
      @client_id = client_id
    end

    def to_json(*_args)
      {
        type: @type,
        payload: @payload,
        timestamp: @timestamp.to_i,
        client_id: @client_id
      }.to_json
    end

    def to_s
      "[#{@type}] #{@payload}"
    end

    def self.from_json(json_string)
      data = JSON.parse(json_string, symbolize_names: true)
      new(
        type: data[:type],
        payload: data[:payload],
        client_id: data[:client_id]
      )
    rescue JSON::ParserError => e
      raise ArgumentError, "Invalid JSON: #{e.message}"
    end

    def self.parse(raw_data)
      # Try to parse as JSON first
      from_json(raw_data.strip)
    rescue ArgumentError
      # If not JSON, create a simple text message
      new(type: 'text', payload: raw_data.strip)
    end
  end
end
