require "spec"
require "../src/rethinkdb"
include RethinkDB::Shortcuts

module Generators
  @@i = 0
  private def self.i
    @@i = @@i+1
  end

  def self.random_table
    "test_#{Time.now.epoch}_#{rand(10000)}_#{i}"
  end

  def self.random_table
    yield random_table
  end

  def self.random_pk
    "pk_#{Time.now.epoch}_#{rand(100)}_#{i}"
  end

  def self.random_pk
    yield random_pk
  end
end

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
