require "./rethinkdb-crystal/*"

def r
  RethinkDB
end

def r(any)
  r.expr(any)
end

module RethinkDB
  def self.connect(options)
    Connection.new(options)
  end
end
