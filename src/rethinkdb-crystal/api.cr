require "json"
require "./term"

module RethinkDB
  def self.db(name)
    DBTerm.new(TermType::DB, name)
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
    StreamTerm.new(TermType::RANGE, a)
  end

  def self.range(a, b)
    StreamTerm.new(TermType::RANGE, a, b)
  end

  def self.range(a, b, step)
    StreamTerm.new(TermType::RANGE, a, b, step)
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
      DatumTerm.new(TermType::TYPE_OF, self)
    end

    def coerce_to(target)
      DatumTerm.new(TermType::COERCE_TO, self, target)
    end

    def count
      DatumTerm.new(TermType::COUNT, self)
    end
  end

  class DatumTerm
    def default(value)
      DatumTerm.new(TermType::DEFAULT, self, value)
    end

    def split
      DatumTerm.new(TermType::SPLIT, self)
    end

    def split(sep)
      DatumTerm.new(TermType::SPLIT, self, sep)
    end

    def split(sep, max)
      DatumTerm.new(TermType::SPLIT, self, sep, max)
    end

    def slice(start)
      DatumTerm.new(TermType::SLICE, self, start)
    end

    def slice(start, size)
      DatumTerm.new(TermType::SLICE, self, start, size)
    end

    def upcase
      DatumTerm.new(TermType::UPCASE, self)
    end

    def downcase
      DatumTerm.new(TermType::DOWNCASE, self)
    end

    def +(other)
      DatumTerm.new(TermType::ADD, self, other)
    end

    def add(*others)
      DatumTerm.new(TermType::ADD, self, *others)
    end

    def -(other)
      DatumTerm.new(TermType::SUB, self, other)
    end

    def sub(*others)
      DatumTerm.new(TermType::SUB, self, *others)
    end

    def *(other)
      DatumTerm.new(TermType::MUL, self, other)
    end

    def mul(*others)
      DatumTerm.new(TermType::MUL, self, *others)
    end

    def /(other)
      DatumTerm.new(TermType::DIV, self, other)
    end

    def div(*others)
      DatumTerm.new(TermType::DIV, self, *others)
    end

    def %(other)
      DatumTerm.new(TermType::MOD, self, other)
    end

    def mod(*others)
      DatumTerm.new(TermType::MOD, self, *others)
    end

    def floor()
      DatumTerm.new(TermType::FLOOR, self)
    end

    def ceil()
      DatumTerm.new(TermType::CEIL, self)
    end

    def round()
      DatumTerm.new(TermType::ROUND, self)
    end

    def >(other)
      DatumTerm.new(TermType::GT, self, other)
    end

    def gt(other)
      DatumTerm.new(TermType::GT, self, other)
    end

    def >=(other)
      DatumTerm.new(TermType::GE, self, other)
    end

    def ge(other)
      DatumTerm.new(TermType::GE, self, other)
    end

    def <(other)
      DatumTerm.new(TermType::LT, self, other)
    end

    def lt(other)
      DatumTerm.new(TermType::LT, self, other)
    end

    def <=(other)
      DatumTerm.new(TermType::LE, self, other)
    end

    def le(other)
      DatumTerm.new(TermType::LE, self, other)
    end

    def ==(other)
      DatumTerm.new(TermType::EQ, self, other)
    end

    def eq(other)
      DatumTerm.new(TermType::EQ, self, other)
    end

    def !=(other)
      DatumTerm.new(TermType::NE, self, other)
    end

    def ne(other)
      DatumTerm.new(TermType::NE, self, other)
    end

    def &(other)
      DatumTerm.new(TermType::AND, self, other)
    end

    def and(*others)
      DatumTerm.new(TermType::AND, self, *others)
    end

    def |(other)
      DatumTerm.new(TermType::OR, self, other)
    end

    def or(*others)
      DatumTerm.new(TermType::OR, self, *others)
    end

    def ~
      DatumTerm.new(TermType::NOT, self)
    end

    def not
      DatumTerm.new(TermType::NOT, self)
    end

    def [](key)
      DatumTerm.new(TermType::BRACKET, self, key)
    end
  end

  class StreamTerm
    def limit(n)
      StreamTerm.new(TermType::LIMIT, self, n)
    end

    def [](key)
      StreamTerm.new(TermType::BRACKET, self, key)
    end
  end

  class DBTerm < Term
    def table(name)
      TableTerm.new(TermType::TABLE, self, name)
    end
  end

  class TableTerm < StreamTerm
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
