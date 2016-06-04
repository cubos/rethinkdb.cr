require "./term"

module RethinkDB
  class RowsTerm < StreamTerm
    def update(doc)
      DatumTerm.new(TermType::UPDATE, [self, doc])
    end

    def update
      DatumTerm.new(TermType::UPDATE, [self, Func.arity1 {|row| yield(row) }])
    end

    def replace(doc)
      DatumTerm.new(TermType::REPLACE, [self, doc])
    end

    def replace
      DatumTerm.new(TermType::REPLACE, [self, Func.arity1 {|row| yield(row) }])
    end

    def filter(callable)
      RowsTerm.new(TermType::FILTER, [self, callable])
    end

    def filter
      RowsTerm.new(TermType::FILTER, [self, Func.arity1 {|row| yield(row) }])
    end

    def filter(**kargs)
      RowsTerm.new(TermType::FILTER, [self, Func.arity1 {|row| yield(row) }], kargs)
    end
  end
end
