require "socket/socket"
require "socket/tcp_socket"
require "json"
require "./serialization"
require "./constants"

module RethinkDB
  class Connection
    def initialize(options)
      host = options[:host]? || "localhost"
      port = options[:port]? || 28015
      @db = options[:db]? || "test"
      auth_key = options[:auth_key]? || ""
      timeout = options[:timeout]? || 20

      @next_id = 1u64
      @open = true

      @sock = TCPSocket.new(host, port)
      @sock.write_bytes(Version::V0_4.to_u32, IO::ByteFormat::LittleEndian)
      @sock.write_bytes(auth_key.bytesize, IO::ByteFormat::LittleEndian)
      @sock.write(auth_key.to_slice)
      @sock.write_bytes(Protocol::JSON.to_u32, IO::ByteFormat::LittleEndian)

      error = @sock.gets('\0')
      unless error
        raise ReqlDriverError.new
      end

      unless error.chop == "SUCCESS"
        raise ReqlDriverError.new(error.chop)
      end

      @channels = {} of UInt64 => Channel::Unbuffered(String)
      @next_query_id = 1_u64

      spawn do
        while @open
          id = @sock.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
          size = @sock.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
          slice = Slice(UInt8).new(size)
          @sock.read(slice)
          @channels[id]?.try &.send String.new(slice)
        end
        @sock.close
      end
    end

    def close
      @open = false
    end

    protected def next_id
      id = @next_id
      @next_id += 1
      id
    end

    class Response
      JSON.mapping({
        t: ResponseType,
        r: Array(QueryResult),
        e: {type: ErrorType, nilable: true},
        b: {type: Array(JSON::Any), nilable: true},
        p: {type: JSON::Any, nilable: true},
        n: {type: Array(Int32), nilable: true}
      })
    end

    class ResponseStream
      getter id : UInt64
      @channel : Channel::Unbuffered(String)

      def initialize(@conn : Connection)
        @id = @conn.next_id
        @channel = @conn.@channels[id] = Channel(String).new
      end

      def query_term(term)
        send_query [QueryType::START, term.to_reql, {} of String => String].to_json
        begin
          read_response
        rescue e : ReqlClientError
          puts e.message
          puts [QueryType::START, term.to_reql, {} of String => String].to_json
          raise e
        end
      end

      def query_continue
        send_query [QueryType::CONTINUE].to_json
        read_response
      end

      private def send_query(query)
        if @id == 0
          raise ReqlDriverError.new("Bug: Using already finished stream.")
        end

        @conn.@sock.write_bytes(@id, IO::ByteFormat::LittleEndian)
        @conn.@sock.write_bytes(query.bytesize, IO::ByteFormat::LittleEndian)
        @conn.@sock.write(query.to_slice)
      end

      private def read_response
        response = Response.from_json(@channel.receive)

        unless response.t == ResponseType::SUCCESS_PARTIAL
          finish
        end

        if response.t == ResponseType::CLIENT_ERROR
          raise ReqlClientError.new(response.r[0].to_s)
        elsif response.t == ResponseType::COMPILE_ERROR
          raise ReqlCompileError.new(response.r[0].to_s)
        elsif response.t == ResponseType::RUNTIME_ERROR
          msg = response.r[0].to_s
          case response.e
          when ErrorType::QUERY_LOGIC
            raise ReqlQueryLogicError.new(msg)
          when ErrorType::USER
            raise ReqlUserError.new(msg)
          else
            raise ReqlRunTimeError.new(response.e.to_s + ": " + msg)
          end
        end

        response
      end

      private def finish
        @conn.@channels.delete @id
        @id = 0u64
      end
    end

    def query_error(term)
      stream = ResponseStream.new(self)
      response = stream.query_term(term)

      raise ReqlDriverError.new("An r.error should never return successfully")
    end

    def query_datum(term)
      stream = ResponseStream.new(self)
      response = stream.query_term(term)

      unless response.t == ResponseType::SUCCESS_ATOM
        raise ReqlDriverError.new("Expected SUCCESS_ATOM but got #{response.t}")
      end

      return response.r[0]
    end

    def query_cursor(term)
      stream = ResponseStream.new(self)
      response = stream.query_term(term)

      unless response.t == ResponseType::SUCCESS_SEQUENCE || response.t == ResponseType::SUCCESS_PARTIAL
        raise ReqlDriverError.new("Expected SUCCESS_SEQUENCE or SUCCESS_PARTIAL but got #{response.t}")
      end

      Cursor.new(stream, response)
    end
  end

  class Cursor
    include Iterator(QueryResult)

    def initialize(@stream : Connection::ResponseStream, @response : Connection::Response)
      @index = 0
    end

    def fetch_next
      @response = @stream.query_continue
      @index = 0

      unless @response.t == ResponseType::SUCCESS_SEQUENCE || @response.t == ResponseType::SUCCESS_PARTIAL
        raise ReqlDriverError.new("Expected SUCCESS_SEQUENCE or SUCCESS_PARTIAL but got #{@response.t}")
      end
    end

    def next
      while @index == @response.r.size
        if @response.t == ResponseType::SUCCESS_SEQUENCE
          return Iterator::Stop.new
        else
          fetch_next
        end
      end

      value = @response.r[@index]
      @index += 1
      return value
    end
  end
end
