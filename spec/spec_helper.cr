require "spec"
require "../src/rethinkdb-crystal"

begin
  r.connect({host: "rethinkdb"}).close
  $rethinkdb_host = "rethinkdb"
rescue
end

begin
  r.connect({host: "localhost"}).close
  $rethinkdb_host = "localhost"
rescue
end

if $rethinkdb_host
  puts "Identified RethinkDB at tcp://#{$rethinkdb_host}"
else
  STDERR.puts "Unable to identify running instance of RethinkDB. Run it at 'localhost' or 'rethinkdb'."
  exit
end
