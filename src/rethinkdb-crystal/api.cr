require "json"
require "./term"

module RethinkDB
  def self.db(name)
    DBTerm.new(TermType::DB, [name])
  end

  def self.expr(any)
    DatumTerm.new(any.to_reql)
  end

  def self.now()
    DatumTerm.new(TermType::NOW)
  end

  def self.range
    StreamTerm.new(TermType::RANGE)
  end

  def self.range(a)
    StreamTerm.new(TermType::RANGE, [a])
  end

  def self.range(a, b)
    StreamTerm.new(TermType::RANGE, [a, b])
  end

  def self.range(a, b, step)
    StreamTerm.new(TermType::RANGE, [a, b, step])
  end

  def self.do()
    DatumTerm.new(TermType::FUNCALL)
  end

  def self.do(*args)
    args = args.to_a
    DatumTerm.new(TermType::FUNCALL, [args.pop] + args)
  end

  def self.do(*args)
    args = args + {nil, nil, nil, nil, nil}
    DatumTerm.new(TermType::FUNCALL, [
      Func.arity5 {|a, b, c, d, e| yield(a, b, c, d, e) },
      args[0], args[1], args[2], args[3], args[4]
    ])
  end

  def self.branch(*args)
    DatumTerm.new(TermType::BRANCH, args.to_a)
  end

  def self.error(reason)
    ErrorTerm.new(TermType::ERROR, [reason])
  end

  def self.js(code)
    DatumTerm.new(TermType::JAVASCRIPT, [code])
  end

  def self.js(code, options)
    DatumTerm.new(TermType::JAVASCRIPT, [code], options)
  end

  macro define_prefix_notation(*names)
    {% for name in names %}
      def self.{{name.id}}(target, *args)
        r(target).{{name.id}}(*args)
      end
    {% end %}
  end

  define_prefix_notation type_of
  define_prefix_notation add, sub, mul, div, mod
  define_prefix_notation floor, ceil, round
  define_prefix_notation gt, ge, lt, le, eq, ne
  define_prefix_notation and, or, not

  class Term
    def type_of
      DatumTerm.new(TermType::TYPE_OF, [self])
    end

    def coerce_to(target)
      DatumTerm.new(TermType::COERCE_TO, [self, target])
    end

    def count
      DatumTerm.new(TermType::COUNT, [self])
    end
  end

  class DatumTerm
    def default(value)
      DatumTerm.new(TermType::DEFAULT, [self, value])
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
  end

  class StreamTerm
    def limit(n)
      StreamTerm.new(TermType::LIMIT, [self, n])
    end

    def [](key)
      StreamTerm.new(TermType::BRACKET, [self, key])
    end

    def filter(callable)
      StreamTerm.new(TermType::FILTER, [self, callable])
    end

    def filter
      StreamTerm.new(TermType::FILTER, [self, Func.arity1 {|row| yield(row) }])
    end

    def map(callable)
      StreamTerm.new(TermType::MAP, [self, callable])
    end

    def map
      StreamTerm.new(TermType::MAP, [self, Func.arity1 {|row| yield(row) }])
    end

    def for_each(callable)
      DatumTerm.new(TermType::FOR_EACH, [self, callable])
    end

    def for_each
      DatumTerm.new(TermType::FOR_EACH, [self, Func.arity1 {|row| yield(row) }])
    end
  end

  class DBTerm < Term
    def table(name)
      TableTerm.new(TermType::TABLE, [self, name])
    end

    def table_create(name)
      DatumTerm.new(TermType::TABLE_CREATE, [self, name])
    end

    def table_drop(name)
      DatumTerm.new(TermType::TABLE_DROP, [self, name])
    end

    def table_list
      DatumTerm.new(TermType::TABLE_LIST, [self])
    end
  end

  class RowsTerm < StreamTerm
    def update(doc)
      DatumTerm.new(TermType::UPDATE, [self, doc])
    end

    def replace(doc)
      DatumTerm.new(TermType::REPLACE, [self, doc])
    end
  end

  class RowTerm < DatumTerm
    def update(doc)
      DatumTerm.new(TermType::UPDATE, [self, doc])
    end

    def replace(doc)
      DatumTerm.new(TermType::REPLACE, [self, doc])
    end

    def delete
      DatumTerm.new(TermType::DELETE, [self])
    end
  end

  class TableTerm < RowsTerm
    def insert(doc)
      DatumTerm.new(TermType::INSERT, [self, doc])
    end

    def get(key)
      RowTerm.new(TermType::GET, [self, key])
    end
  end
end

struct Number
  def +(other : RethinkDB::DatumTerm)
    r(self) + other
  end

  def -(other : RethinkDB::DatumTerm)
    r(self) - other
  end

  def *(other : RethinkDB::DatumTerm)
    r(self) * other
  end

  def /(other : RethinkDB::DatumTerm)
    r(self) / other
  end

  def %(other : RethinkDB::DatumTerm)
    r(self) % other
  end
end
