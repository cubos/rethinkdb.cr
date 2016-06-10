require "./term"

module RethinkDB
  class RowTerm < DatumTerm
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

    def delete
      DatumTerm.new(TermType::DELETE, [self])
    end
  end
end
