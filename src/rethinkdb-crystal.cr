require "./rethinkdb-crystal/*"

module RethinkDB
  module Shortcuts
    def r
      RethinkDB
    end

    def r(any)
      r.expr(any)
    end
  end

  def self.connect(options)
    Connection.new(options)
  end
end
