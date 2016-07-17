require "./term"

module RethinkDB
  class GroupedStreamTerm < DatumTerm
    def ungroup
      DatumTerm.new(TermType::UNGROUP, [self])
    end

    def do(*args)
      r.do(self, *args)
    end

    def do(*args)
      r.do(self, *args) {|a, b, c, d, e| yield(a, b, c, d, e) }
    end

    def count
      GroupedStreamTerm.new(TermType::COUNT, [self])
    end

    def limit(n)
      GroupedStreamTerm.new(TermType::LIMIT, [self, n])
    end

    def [](key)
      GroupedStreamTerm.new(TermType::BRACKET, [self, key])
    end

    def filter(callable)
      GroupedStreamTerm.new(TermType::FILTER, [self, callable])
    end

    def filter
      GroupedStreamTerm.new(TermType::FILTER, [self, Func.arity1 {|row| yield(row) }])
    end

    def map(callable)
      GroupedStreamTerm.new(TermType::MAP, [self, callable])
    end

    def map
      GroupedStreamTerm.new(TermType::MAP, [self, Func.arity1 {|row| yield(row) }])
    end

    def for_each(callable)
      GroupedStreamTerm.new(TermType::FOR_EACH, [self, callable])
    end

    def for_each
      GroupedStreamTerm.new(TermType::FOR_EACH, [self, Func.arity1 {|row| yield(row) }])
    end

    def order_by
      GroupedStreamTerm.new(TermType::ORDER_BY, [self, Func.arity1 {|row| yield(row) }])
    end

    def order_by(**kargs)
      GroupedStreamTerm.new(TermType::ORDER_BY, [self], kargs)
    end

    def order_by(callable)
      GroupedStreamTerm.new(TermType::ORDER_BY, [self, callable])
    end

    def sum
      GroupedStreamTerm.new(TermType::SUM, [self])
    end

    def sum
      GroupedStreamTerm.new(TermType::SUM, [self, Func.arity1 {|row| yield(row) }])
    end

    def sum(field)
      GroupedStreamTerm.new(TermType::SUM, [self, field])
    end

    def avg
      GroupedStreamTerm.new(TermType::AVG, [self])
    end

    def avg
      GroupedStreamTerm.new(TermType::AVG, [self, Func.arity1 {|row| yield(row) }])
    end

    def avg(field)
      GroupedStreamTerm.new(TermType::AVG, [self, field])
    end

    def min
      GroupedStreamTerm.new(TermType::MIN, [self])
    end

    def min
      GroupedStreamTerm.new(TermType::MIN, [self, Func.arity1 {|row| yield(row) }])
    end

    def min(field)
      GroupedStreamTerm.new(TermType::MIN, [self, field])
    end

    def max
      GroupedStreamTerm.new(TermType::MAX, [self])
    end

    def max
      GroupedStreamTerm.new(TermType::MAX, [self, Func.arity1 {|row| yield(row) }])
    end

    def max(field)
      GroupedStreamTerm.new(TermType::MAX, [self, field])
    end

    def group(**options)
      GroupedStreamTerm.new(TermType::GROUP, [self], options)
    end

    def group(field, **options)
      GroupedStreamTerm.new(TermType::GROUP, [self, field], options)
    end

    def group
      GroupedStreamTerm.new(TermType::GROUP, [self, Func.arity1 {|row| yield(row) }])
    end

    def reduce(callable)
      GroupedStreamTerm.new(TermType::REDUCE, [self, callable])
    end

    def reduce
      GroupedStreamTerm.new(TermType::REDUCE, [self, Func.arity2 {|a, b| yield(a, b) }])
    end

    def union(other)
      GroupedStreamTerm.new(TermType::REDUCE, [self, other])
    end

    def distinct
      GroupedStreamTerm.new(TermType::DISTINCT, [self])
    end

    def distinct(options : Hash|NamedTuple)
      GroupedStreamTerm.new(TermType::DISTINCT, [self], options)
    end

    def between(a, b, options : Hash|NamedTuple)
      GroupedStreamTerm.new(TermType::BETWEEN, [self, a, b], options)
    end
  end
end
