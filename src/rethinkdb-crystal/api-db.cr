require "./term"

module RethinkDB
  def self.table(name)
    TableTerm.new(TermType::TABLE, [name])
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
end
