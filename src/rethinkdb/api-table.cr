require "./term"

module RethinkDB
  class TableTerm < RowsTerm
    def insert(doc)
      DatumTerm.new(TermType::INSERT, [self, doc])
    end

    def get(key)
      RowTerm.new(TermType::GET, [self, key])
    end

    def index_create(key)
      DatumTerm.new(TermType::INDEX_CREATE, [self, key])
    end

    def index_create(key, **options)
      DatumTerm.new(TermType::INDEX_CREATE, [self, key], options)
    end

    def index_create(key, **options)
      DatumTerm.new(TermType::INDEX_CREATE, [self, key, Func.arity1 {|row| yield(row) }], options)
    end

    def index_wait(name)
      DatumTerm.new(TermType::INDEX_WAIT, [self, name])
    end

    def index_list
      DatumTerm.new(TermType::INDEX_LIST, [self])
    end
  end
end
