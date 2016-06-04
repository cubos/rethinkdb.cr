require "./term"

module RethinkDB
  class Term
    def type_of
      DatumTerm.new(TermType::TYPE_OF, [self])
    end

    def coerce_to(target)
      DatumTerm.new(TermType::COERCE_TO, [self, target])
    end
  end
end
