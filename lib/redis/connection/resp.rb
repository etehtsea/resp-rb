require 'redis/connection/registry'
require 'redis/errors'
require 'resp'

class Redis
  module Connection
    class Resp
      def self.connect(config)
        conn_type = config[:scheme] == 'unix' ? :unix : :tcp
        connection = ::RESP::Connection.public_send(:"connect_#{conn_type}", config)

        new(connection)
      end

      def initialize(connection)
        @connection = connection
      end

      def connected?
        @connection && @connection.connected?
      end

      def timeout=(timeout)
        @connection.timeout = timeout > 0 ? timeout : nil
      end

      def disconnect
        @connection.close
      end

      def write(command)
        @connection.send_command(command)
      end

      def read
        reply = @connection.read_response
        reply = encode(reply) if reply.is_a?(String)
        reply = CommandError.new(reply.message) if reply.is_a?(RESP::Protocol::RError)
        reply
      rescue RESP::Protocol::ParserError => e
        raise Redis::ProtocolError.new(e.message)
      end

      if defined?(Encoding::default_external)
        def encode(string)
          string.force_encoding(Encoding::default_external)
        end
      else
        def encode(string)
          string
        end
      end
    end
  end
end

Redis::Connection.drivers << Redis::Connection::Resp