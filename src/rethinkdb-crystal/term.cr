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

    def initialize(type : RethinkDB::TermType, args : Array)
      args = args.map(&.to_reql.as(JSON::Type))
      @reql = [
        type.to_i64.as(JSON::Type),
        args.as(JSON::Type)
      ].as(JSON::Type)
    end

    def initialize(type : RethinkDB::TermType, args : Array, options)
      args = args.map(&.to_reql.as(JSON::Type))
      @reql = [
        type.to_i64.as(JSON::Type),
        args.as(JSON::Type),
        options.to_reql.as(JSON::Type)
      ].map(&.as(JSON::Type)).as(JSON::Type)
    end

    def to_reql
      @reql
    end
  end

  class Func < Term
    @@vars = 0

    def self.arity0
      super(TermType::FUNC, [[] of Int64, yield])
    end

    def self.arity1
      vars = {1}.map {@@vars += 1}
      args = vars.map {|v| DatumTerm.new(TermType::VAR, [v]) }
      result = yield(args[0])
      Term.new(TermType::FUNC, [vars.to_a, result])
    end

    def self.arity2
      vars = {1, 2}.map {@@vars += 1}
      args = vars.map {|v| DatumTerm.new(TermType::VAR, [v]) }
      result = yield(args[0], args[1])
      Term.new(TermType::FUNC, [vars.to_a, result])
    end

    def self.arity3
      vars = {1, 2, 3}.map {@@vars += 1}
      args = vars.map {|v| DatumTerm.new(TermType::VAR, [v]) }
      result = yield(args[0], args[1], args[2])
      Term.new(TermType::FUNC, [vars.to_a, result])
    end

    def self.arity4
      vars = {1, 2, 3, 4}.map {@@vars += 1}
      args = vars.map {|v| DatumTerm.new(TermType::VAR, [v]) }
      result = yield(args[0], args[1], args[2], args[3])
      Term.new(TermType::FUNC, [vars.to_a, result])
    end

    def self.arity5
      vars = {1, 2, 3, 4, 5}.map {@@vars += 1}
      args = vars.map {|v| DatumTerm.new(TermType::VAR, [v]) }
      result = yield(args[0], args[1], args[2], args[3], args[4])
      Term.new(TermType::FUNC, [vars.to_a, result])
    end
  end

  class ErrorTerm < Term
    def run(conn)
      conn.query_error(self)
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
