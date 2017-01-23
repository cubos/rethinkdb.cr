require "spec"
require "../src/rethinkdb"
include RethinkDB::Shortcuts

module Fixtures
  class TestDB
    @@host = uninitialized String

    begin
    r.connect({host: "rethinkdb"}).close
    @@host = "rethinkdb"
    rescue
    end

    begin
      r.connect({host: "localhost"}).close
      @@host = "localhost"
    rescue
    end

    if @@host
      puts "Identified RethinkDB at tcp://#{@@host}"
    else
      STDERR.puts "Unable to identify running instance of RethinkDB. Run it at 'localhost' or 'rethinkdb'."
      exit
    end 

    def self.host
      @@host
    end

    def self.conn
      r.connect({host: host})
    end
  end
end
