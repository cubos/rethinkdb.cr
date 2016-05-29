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

  def self.range(a, b)
    StreamTerm.new(TermType::RANGE, a, b)
  end

  macro define_prefix_notation(name)
    def self.{{name.id}}(target, *args)
      r(target).{{name.id}}(*args)
    end
  end

  define_prefix_notation type_of

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
  end

  class DBTerm < Term
    def table(name)
      TableTerm.new(TermType::TABLE, self, name)
    end
  end

  class TableTerm < StreamTerm
  end
end
