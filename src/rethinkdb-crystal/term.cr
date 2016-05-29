require "json"

module RethinkDB
  class Term
    @reql : JSON::Type

    def initialize(any : JSON::Type)
      @reql = any.as(JSON::Type)
    end

    def initialize(type : RethinkDB::TermType)
      @reql = [type.to_i64.as(JSON::Type)].as(JSON::Type)
    end

    def initialize(type : RethinkDB::TermType, *args)
      args = args.to_a.map(&.to_reql.as(JSON::Type))
      @reql = [type.to_i64.as(JSON::Type), args.as(JSON::Type)].as(JSON::Type)
    end

    def to_reql
      @reql
    end
  end

  class DatumTerm < Term
    def run(conn)
      conn.query_datum(self)
    end
  end

  class StreamTerm < Term
    def run(conn)
      conn.query_cursor(self)
    end
  end
end
