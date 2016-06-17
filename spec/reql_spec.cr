require "./spec_helper"

$reql_conn : RethinkDB::Connection
$reql_conn = r.connect({host: $rethinkdb_host})
r.db("test").table_list.for_each do |name|
  r.db("test").table_drop(name)
end.run($reql_conn)

def match_reql_output(result)
  result = result.to_a if result.is_a? RethinkDB::Cursor
  matcher = with ReqlMatchers.new yield
  recursive_match result, matcher
end

def recursive_match(result, target)
  case target
  when Matcher
    target.match(result)
  when Array
    result.raw.should be_a Array(RethinkDB::QueryResult::Type)
    result.size.should eq target.size
    result.size.times do |i|
      recursive_match result[i], target[i]
    end
  when Hash
    result.raw.should be_a Hash(String, RethinkDB::QueryResult::Type)
    (result.keys - result.keys).size.should eq 0
    result.keys.each do |key|
      recursive_match result[key], target[key]
    end
  else
    result.should eq target
  end
end

def recursive_match(result : Array, target)
  result.should be_a Array(RethinkDB::QueryResult)
  result.size.should eq target.size
  result.size.times do |i|
    recursive_match result[i], target[i]
  end
end

describe RethinkDB do
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/array.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/bool.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/null.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/number.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/object.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/string.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/typeof.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/uuid.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/add.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/aliases.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/div.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/floor_ceil_round.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/logic.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/math.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/mod.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/mul.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/sub.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/aggregation.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/control.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/default.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/range.yaml") }}
end

struct ReqlMatchers
  def int_cmp(value)
    IntCmpMatcher.new(value.to_i64)
  end

  def float_cmp(value)
    FloatCmpMatcher.new(value.to_f64)
  end

  def uuid
    UUIDMatcher.new
  end

  def arrlen(len, matcher)
    ArrayMatcher.new(len, matcher)
  end

  def partial(matcher)
    PartialMatcher.new(matcher)
  end
end

abstract struct Matcher
end

struct IntCmpMatcher < Matcher
  def initialize(@value : Int64)
  end

  def match(result)
    result.should eq @value
    result.raw.should be_a Int64
  end
end

struct FloatCmpMatcher < Matcher
  def initialize(@value : Float64)
  end

  def match(result)
    result.should eq @value
    result.raw.should be_a Float64
  end
end

struct UUIDMatcher < Matcher
  def match(result)
    result.raw.should be_a String
    result.as_s.should Spec::MatchExpectation.new(/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
  end
end

struct ArrayMatcher(T) < Matcher
  def initialize(@size : Int32, @matcher : T)
  end

  def match(result)
    result.raw.should be_a Array(RethinkDB::QueryResult::Type)
    result.size.should eq @size
    result.each do |value|
      recursive_match value, @matcher
    end
  end
end

struct PartialMatcher(T) < Matcher
  def initialize(@object : Hash(String, T))
  end

  def match(result)
    result.raw.should be_a Hash(String, RethinkDB::QueryResult::Type)
    @object.keys.each do |key|
      result.keys.includes?(key).should be_true
      recursive_match result[key], @object[key]
    end
  end
end
