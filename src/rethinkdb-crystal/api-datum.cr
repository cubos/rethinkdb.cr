require "./term"

module RethinkDB
  class DatumTerm
    def count
      DatumTerm.new(TermType::COUNT, [self])
    end

    def count
      DatumTerm.new(TermType::COUNT, [self, Func.arity1 {|row| yield(row) }])
    end

    def default(value)
      DatumTerm.new(TermType::DEFAULT, [self, value])
    end

    def default
      DatumTerm.new(TermType::DEFAULT, [self, Func.arity1 {|row| yield(row) }])
    end

    def split
      DatumTerm.new(TermType::SPLIT, [self])
    end

    def split(sep)
      DatumTerm.new(TermType::SPLIT, [self, sep])
    end

    def split(sep, max)
      DatumTerm.new(TermType::SPLIT, [self, sep, max])
    end

    def slice(start)
      DatumTerm.new(TermType::SLICE, [self, start])
    end

    def slice(start, size)
      DatumTerm.new(TermType::SLICE, [self, start, size])
    end

    def upcase
      DatumTerm.new(TermType::UPCASE, [self])
    end

    def downcase
      DatumTerm.new(TermType::DOWNCASE, [self])
    end

    def +(other)
      DatumTerm.new(TermType::ADD, [self, other])
    end

    def add(*others)
      DatumTerm.new(TermType::ADD, [self] + others.to_a)
    end

    def -(other)
      DatumTerm.new(TermType::SUB, [self, other])
    end

    def sub(*others)
      DatumTerm.new(TermType::SUB, [self] + others.to_a)
    end

    def *(other)
      DatumTerm.new(TermType::MUL, [self, other])
    end

    def mul(*others)
      DatumTerm.new(TermType::MUL, [self] + others.to_a)
    end

    def /(other)
      DatumTerm.new(TermType::DIV, [self, other])
    end

    def div(*others)
      DatumTerm.new(TermType::DIV, [self] + others.to_a)
    end

    def %(other)
      DatumTerm.new(TermType::MOD, [self, other])
    end

    def mod(*others)
      DatumTerm.new(TermType::MOD, [self] + others.to_a)
    end

    def floor()
      DatumTerm.new(TermType::FLOOR, [self])
    end

    def ceil()
      DatumTerm.new(TermType::CEIL, [self])
    end

    def round()
      DatumTerm.new(TermType::ROUND, [self])
    end

    def >(other)
      DatumTerm.new(TermType::GT, [self, other])
    end

    def gt(other)
      DatumTerm.new(TermType::GT, [self, other])
    end

    def >=(other)
      DatumTerm.new(TermType::GE, [self, other])
    end

    def ge(other)
      DatumTerm.new(TermType::GE, [self, other])
    end

    def <(other)
      DatumTerm.new(TermType::LT, [self, other])
    end

    def lt(other)
      DatumTerm.new(TermType::LT, [self, other])
    end

    def <=(other)
      DatumTerm.new(TermType::LE, [self, other])
    end

    def le(other)
      DatumTerm.new(TermType::LE, [self, other])
    end

    def ==(other)
      DatumTerm.new(TermType::EQ, [self, other])
    end

    def eq(other)
      DatumTerm.new(TermType::EQ, [self, other])
    end

    def !=(other)
      DatumTerm.new(TermType::NE, [self, other])
    end

    def ne(other)
      DatumTerm.new(TermType::NE, [self, other])
    end

    def &(other)
      DatumTerm.new(TermType::AND, [self, other])
    end

    def and(*others)
      DatumTerm.new(TermType::AND, [self] + others.to_a)
    end

    def |(other)
      DatumTerm.new(TermType::OR, [self, other])
    end

    def or(*others)
      DatumTerm.new(TermType::OR, [self] + others.to_a)
    end

    def ~
      DatumTerm.new(TermType::NOT, [self])
    end

    def not
      DatumTerm.new(TermType::NOT, [self])
    end

    def [](key)
      DatumTerm.new(TermType::BRACKET, [self, key])
    end

    def get_field(key)
      DatumTerm.new(TermType::GET_FIELD, [self, key])
    end

    def nth(key)
      DatumTerm.new(TermType::NTH, [self, key])
    end

    def do(*args)
      r.do(self, *args)
    end

    def do(*args)
      r.do(self, *args) {|a, b, c, d, e| yield(a, b, c, d, e) }
    end

    def append(value)
      DatumTerm.new(TermType::APPEND, [self, value])
    end

    def insert_at(index, value)
      DatumTerm.new(TermType::INSERT_AT, [self, index, value])
    end

    def change_at(index, value)
      DatumTerm.new(TermType::CHANGE_AT, [self, index, value])
    end

    def splice_at(index, array)
      DatumTerm.new(TermType::SPLICE_AT, [self, index, array])
    end

    def delete_at(index)
      DatumTerm.new(TermType::DELETE_AT, [self, index])
    end

    def delete_at(begin_index, end_index)
      DatumTerm.new(TermType::DELETE_AT, [self, begin_index, end_index])
    end

    def filter(callable)
      DatumTerm.new(TermType::FILTER, [self, callable])
    end

    def filter
      DatumTerm.new(TermType::FILTER, [self, Func.arity1 {|row| yield(row) }])
    end

    def filter(**kargs)
      DatumTerm.new(TermType::FILTER, [self, Func.arity1 {|row| yield(row) }], kargs)
    end

    def map(callable)
      DatumTerm.new(TermType::MAP, [self, callable])
    end

    def map
      DatumTerm.new(TermType::MAP, [self, Func.arity1 {|row| yield(row) }])
    end

    def for_each(callable)
      DatumTerm.new(TermType::FOR_EACH, [self, callable])
    end

    def for_each
      DatumTerm.new(TermType::FOR_EACH, [self, Func.arity1 {|row| yield(row) }])
    end

    def distinct
      DatumTerm.new(TermType::DISTINCT, [self])
    end

    def reduce(callable)
      DatumTerm.new(TermType::REDUCE, [self, callable])
    end

    def reduce
      DatumTerm.new(TermType::REDUCE, [self, Func.arity2 {|a, b| yield(a, b) }])
    end

    def limit(count)
      DatumTerm.new(TermType::LIMIT, [self, count])
    end

    def sum
      DatumTerm.new(TermType::SUM, [self])
    end

    def sum
      DatumTerm.new(TermType::SUM, [self, Func.arity1 {|row| yield(row) }])
    end

    def sum(field)
      DatumTerm.new(TermType::SUM, [self, field])
    end

    def avg
      DatumTerm.new(TermType::AVG, [self])
    end

    def avg
      DatumTerm.new(TermType::AVG, [self, Func.arity1 {|row| yield(row) }])
    end

    def avg(field)
      DatumTerm.new(TermType::AVG, [self, field])
    end

    def min
      DatumTerm.new(TermType::MIN, [self])
    end

    def min
      DatumTerm.new(TermType::MIN, [self, Func.arity1 {|row| yield(row) }])
    end

    def min(field)
      DatumTerm.new(TermType::MIN, [self, field])
    end

    def max
      DatumTerm.new(TermType::MAX, [self])
    end

    def max
      DatumTerm.new(TermType::MAX, [self, Func.arity1 {|row| yield(row) }])
    end

    def max(field)
      DatumTerm.new(TermType::MAX, [self, field])
    end

    def group(field)
      GroupedStreamTerm.new(TermType::GROUP, [self, field])
    end

    def group
      GroupedStreamTerm.new(TermType::GROUP, [self, Func.arity1 {|row| yield(row) }])
    end

    def union(other)
      StreamTerm.new(TermType::UNION, [self, other])
    end

    def pluck(*args)
      DatumTerm.new(TermType::PLUCK, [self] + args.to_a)
    end

    def without(*fields)
      DatumTerm.new(TermType::WITHOUT, [self] + fields.to_a)
    end

    def contains
      DatumTerm.new(TermType::CONTAINS, [self])
    end

    def contains(other)
      DatumTerm.new(TermType::CONTAINS, [self, other])
    end

    def contains
      DatumTerm.new(TermType::CONTAINS, [self, Func.arity1 {|row| yield(row) }])
    end

    def order_by
      DatumTerm.new(TermType::ORDER_BY, [self, Func.arity1 {|row| yield(row) }])
    end

    def order_by(**kargs)
      DatumTerm.new(TermType::ORDER_BY, [self], kargs.to_h)
    end

    def order_by(callable)
      if callable.is_a? Hash || callable.is_a? NamedTuple
        DatumTerm.new(TermType::ORDER_BY, [self], callable)
      else
        DatumTerm.new(TermType::ORDER_BY, [self, callable])
      end
    end
  end
end
