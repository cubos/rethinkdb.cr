require "./term"

module RethinkDB
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
end
