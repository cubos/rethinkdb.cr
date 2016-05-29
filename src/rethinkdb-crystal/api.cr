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

  macro define_prefix_notation(name)
    def self.{{name.id}}(target, *args)
      r(target).{{name.id}}(*args)
    end
  end

  define_prefix_notation type_of
  define_prefix_notation add
  define_prefix_notation sub
  define_prefix_notation mul
  define_prefix_notation div
  define_prefix_notation mod

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
  end

  class StreamTerm
    def limit(n)
      StreamTerm.new(TermType::LIMIT, self, n)
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
