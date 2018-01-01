require "json"
require "./term"
require "uuid"

alias ReqlType = Nil | Bool | Int64 | Float64 | String | UUID | Array(ReqlType) | Hash(String, ReqlType)

class Array(T)
  def to_reql
    Array(JSON::Type){
      RethinkDB::TermType::MAKE_ARRAY.to_i64,
      map {|x| x.to_reql.as JSON::Type }.as JSON::Type
    }.as JSON::Type
  end
end

struct Tuple
  def to_reql
    Array(JSON::Type){
      RethinkDB::TermType::MAKE_ARRAY.to_i64,
      to_a.map {|x| x.to_reql.as JSON::Type }.as JSON::Type
    }.as JSON::Type
  end
end

struct UUID
  def to_reql
    to_s.to_reql
  end
end


class Hash(K, V)
  def to_reql
    hash = {} of String => JSON::Type
    each do |k, v|
      hash[k.to_s] = v.to_reql
    end
    hash.as JSON::Type
  end
end

struct NamedTuple
  def to_reql
    hash = {} of String => JSON::Type
    each do |k, v|
      hash[k.to_s] = v.to_reql
    end
    hash.as JSON::Type
  end
end

struct Nil
  def to_reql
    self.as JSON::Type
  end
end

struct Int
  def to_reql
    to_i64.as JSON::Type
  end
end

struct Float
  def to_reql
    to_f64.as JSON::Type
  end
end

class String
  def to_reql
    self.as JSON::Type
  end
end

struct Symbol
  def to_reql
    to_s.as JSON::Type
  end
end

struct Bool
  def to_reql
    self.as JSON::Type
  end
end

struct Time
  def to_reql
    Hash(String, JSON::Type){"$reql_type$" => "TIME", "timezone" => "+00:00", "epoch_time" => to_utc.epoch}.as JSON::Type
  end

  struct Span
    def to_reql
      to_i.to_i64.as JSON::Type
    end
  end
end

module RethinkDB
  struct QueryResult
    include Enumerable(self)

    alias Type = Nil | Bool | Int64 | Float64 | String | Time | Array(Type) | Hash(String, Type)
    property raw : Type

    def initialize(pull : JSON::PullParser)
      case pull.kind
      when :null
        @raw = pull.read_null
      when :bool
        @raw = pull.read_bool
      when :int
        @raw = pull.read_int
      when :float
        @raw = pull.read_float
      when :string
        @raw = pull.read_string
      when :begin_array
        ary = [] of Type
        pull.read_array do
          ary << QueryResult.new(pull).raw
        end
        @raw = ary
      when :begin_object
        hash = {} of String => Type
        pull.read_object do |key|
          hash[key] = QueryResult.new(pull).raw
        end
        # case hash["$reql_type$"]?
        # when "TIME"
        #   time = Time.epoch((hash["epoch_time"].as Float64|Int64).to_i)
        #   match = (hash["timezone"].as String).match(/([+-]\d\d):(\d\d)/).not_nil!
        #   time += match[1].to_i.hours
        #   time += match[2].to_i.minutes
        #   @raw = time
        # when "GROUPED_DATA"
        #   grouped = [] of Type
        #   (hash["data"].as Array(Type)).each do |data|
        #     data = data.as Array(Type)
        #     group = data[0].as Type
        #     reduction = data[1].as Type
        #     grouped << {"group" => group, "reduction" => reduction}.as Type
        #   end
        #   @raw = grouped.as Type
        # else
          @raw = hash
        # end
      else
        raise "Unknown pull kind: #{pull.kind}"
      end
    end

    def initialize(@raw : Type)
    end

    def self.transformed(obj : Type, time_format, group_format, binary_format) : Type
      case obj
      when Array
        obj.map {|x| QueryResult.transformed(x, time_format, group_format, binary_format).as Type }.as Type
      when Hash
        if obj["$reql_type$"]? == "TIME" && time_format == "native"
          time = Time.epoch((obj["epoch_time"].as Float64|Int64).to_i)
          match = (obj["timezone"].as String).match(/([+-]\d\d):(\d\d)/).not_nil!
          time += match[1].to_i.hours
          time += match[2].to_i.minutes
          return time.as Type
        end
        if obj["$reql_type$"]? == "GROUPED_DATA" && group_format == "native"
          grouped = [] of Type
          (obj["data"].as Array(Type)).each do |data|
            data = data.as Array(Type)
            group = data[0].as Type
            reduction = data[1].as Type
            grouped << {"group" => group, "reduction" => reduction}.as Type
          end
          return QueryResult.transformed(grouped.as Type, time_format, group_format, binary_format)
        end
        result = {} of String => Type
        obj.each do |key, value|
          result[key] = QueryResult.transformed(value, time_format, group_format, binary_format)
        end
        return result.as Type
      else
        obj
      end
    end

    def transformed(time_format, group_format, binary_format)
      QueryResult.new(QueryResult.transformed(@raw, time_format, group_format, binary_format))
    end

    def size : Int
      case object = @raw
      when Array
        object.size
      when Hash
        object.size
      else
        raise "expected Array or Hash for #size, not #{object.class}"
      end
    end

    def keys
      case object = @raw
      when Hash
        object.keys
      else
        raise "expected Hash for #keys, not #{object.class}"
      end
    end

    def [](index : Int) : QueryResult
      case object = @raw
      when Array
        QueryResult.new object[index]
      else
        raise "expected Array for #[](index : Int), not #{object.class}"
      end
    end

    def []?(index : Int) : QueryResult?
      case object = @raw
      when Array
        value = object[index]?
        value ? QueryResult.new(value) : nil
      else
        raise "expected Array for #[]?(index : Int), not #{object.class}"
      end
    end

    def [](key : String) : QueryResult
      case object = @raw
      when Hash
        QueryResult.new object[key]
      else
        raise "expected Hash for #[](key : String), not #{object.class}"
      end
    end

    def []?(key : String) : QueryResult?
      case object = @raw
      when Hash
        value = object[key]?
        value ? QueryResult.new(value) : nil
      else
        raise "expected Hash for #[]?(key : String), not #{object.class}"
      end
    end

    def each
      case object = @raw
      when Array
        object.each do |elem|
          yield QueryResult.new(elem), QueryResult.new(nil)
        end
      when Hash
        object.each do |key, value|
          yield QueryResult.new(key), QueryResult.new(value)
        end
      else
        raise "expected Array or Hash for #each, not #{object.class}"
      end
    end

    def inspect(io)
      raw.inspect(io)
    end

    def to_s(io)
      raw.to_s(io)
    end

    def ==(other : QueryResult)
      raw == other.raw
    end

    def ==(other)
      raw == other
    end

    def hash
      raw.hash
    end

    def as_nil : Nil
      @raw.as(Nil)
    end

    def as_bool : Bool
      @raw.as(Bool)
    end

    def as_bool? : (Bool | Nil)
      as_bool if @raw.is_a?(Bool)
    end

    def as_i : Int32
      @raw.as(Int).to_i
    end

    def as_i? : (Int32 | Nil)
      as_i if @raw.is_a?(Int)
    end

    def as_i64 : Int64
      @raw.as(Int).to_i64
    end

    def as_i64? : (Int64 | Nil)
      as_i64 if @raw.is_a?(Int64)
    end

    def as_f : Float64
      @raw.as(Float).to_f
    end

    def as_f? : (Float64 | Nil)
      as_f if @raw.is_a?(Float64)
    end

    def as_f32 : Float32
      @raw.as(Float).to_f32
    end

    def as_f32? : (Float32 | Nil)
      as_f32 if (@raw.is_a?(Float32) || @raw.is_a?(Float64))
    end

    def as_s : String
      @raw.as(String)
    end

    def as_s? : (String | Nil)
      as_s if @raw.is_a?(String)
    end

    def as_a : Array(Type)
      @raw.as(Array)
    end

    def as_a? : (Array(Type) | Nil)
      as_a if @raw.is_a?(Array(Type))
    end

    def as_h : Hash(String, Type)
      @raw.as(Hash)
    end

    def as_h? : (Hash(String, Type) | Nil)
      as_h if @raw.is_a?(Hash(String, Type))
    end

    def as_time : Time
      @raw.as(Time)
    end

    def as_time? : (Time | Nil)
      as_time if @raw.is_a?(Time)
    end

    def to_reql
      @raw.to_reql
    end
  end
end
