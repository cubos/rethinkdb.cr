[![Build Status](https://travis-ci.org/CubosTecnologia/rethinkdb-crystal.svg?branch=master)](https://travis-ci.org/CubosTecnologia/rethinkdb-crystal)

# rethinkdb-crystal

This is a [RethinkDB](http://rethinkdb.com/) Driver for the [Crystal Language](http://crystal-lang.org/).

### WARNING: This library is not ready, a LOT of functions are not implemented yet.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  rethinkdb-crystal:
    github: CubosTecnologia/rethinkdb-crystal
```

## Usage

This library is meant to be compactible with RethinkDB's Ruby API. Thus, all [official documentation](http://rethinkdb.com/api/ruby/) should be valid here. If you find something that behaves differently, please [open an issue](https://github.com/CubosTecnologia/rethinkdb-crystal/issues/new).

```crystal
require "rethinkdb-crystal"
include RethinkDB::Shotcuts

# Let’s connect and create a table:

conn = r.connect({host: "localhost"})
r.db("test").table_create("tv_shows").run(conn)

# Now, let’s insert some JSON documents into the table:

r.table("tv_shows").insert([
  {name: "Star Trek TNG", episodes: 178},
  {name: "Battlestar Galactica", episodes: 75}
]).run(conn)

# We’ve just inserted two rows into the tv_shows table. Let’s verify the number of rows inserted:

pp r.table("tv_shows").count().run(conn)

# Finally, let’s do a slightly more sophisticated query. Let’s find all shows with more than 100 episodes.

p r.table("tv_shows").filter {|show| show["episodes"] > 100 }.run(conn).to_a

# As a result, we of course get the best science fiction show in existence.
```

## Contributing

1. Fork it ( https://github.com/CubosTecnologia/rethinkdb-crystal/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- **[Cubos Tecnologia](https://cubos.io/)**
- [lbguilherme](https://github.com/lbguilherme) - maintainer
