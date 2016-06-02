require "yaml"

def yaml_fixes(str)
  str = str.gsub("\\", "\\\\")
  str = str.gsub(/(\w+): (.+)\n/) do
    var = $1
    value = $2
    "#{var}: \"#{value.gsub("\"", "\\\"")}\"\n"
  end
  str
end

def quotes_fixes(str)
  str = str.gsub(/'([^']*)'/) { "\"#{$1.gsub("\"", "\\\"")}\"" }
  str
end

def language_fixes(str)
  lang_replaces = {
    "None" => "nil",
    "null" => "nil",
    "True" => "true",
    "False" => "false"
  }
  regex = /([^"'\w]|^)(#{lang_replaces.keys.join("|")})([^"'\w]|$)/
  str = str.gsub(regex) do
    "#{$1}#{lang_replaces[$2]}#{$3}"
  end
  str = quotes_fixes(str)
  str = str.gsub("[]", "[] of Int32")
  str = str.gsub(/([^\)\s]\s*){}/) { "#{$1}{} of String => Int32" }
  str = str.gsub(/^{}$/, "{} of String => Int32")
  str = str.gsub(/([^\\])\":/) { "#{$1}\" => " }
  str = str.gsub(/(\w+):/) { "#{$1}: " }
  str = str.gsub(/(\d+):/) { "\"#{$1}\" => " }
  str
end

data = YAML.parse(yaml_fixes File.read(ARGV[0]))

puts "describe #{data["desc"].inspect} do"
if tables = data["table_variable_name"]?
  puts
  tables.as_s.split(", ").each_with_index do |tablevar, i|
    random_name = "test_#{Time.now.epoch}_#{rand(10000)}_#{i+1}"
    puts "  r.db(\"test\").table_create(#{random_name.inspect}).run($reql_conn)"
    puts "  #{tablevar} = r.db(\"test\").table(#{random_name.inspect})"
  end
end
data["tests"].each_with_index do |test, i|
  if d = test["def"]?
    puts "  #{language_fixes (d["rb"]? || d["cd"]).as_s}"
  elsif test["ot"]? == nil && (test["rb"]? || test["cd"]?)
    assign = (language_fixes (test["rb"]? || test["cd"]).as_s).split("=")
    var = assign[0].strip
    value = assign[1].strip
    puts "  #{var} = #{value}.run($reql_conn).as_i"
  else test["ot"]?
    subtests = test["rb"]? || test["cd"]?
    next unless subtests
    next if subtests == ""
    subtests = [subtests] unless subtests.raw.is_a? Array
    subtests = subtests.map &.as_s

    output = test["ot"]
    unless output.raw.is_a? String
      output = output["rb"]? || output["cd"]
    end
    output = quotes_fixes output.as_s
    next if output =~ /ReqlCompileError/ && output =~ /argument/
    next if output =~ /ReqlCompileError/ && output =~ /Object keys must be strings/
    next if output =~ /ReqlQueryLogicError/ && output =~ /Expected function with \d+ argument/
    next if output =~ /ReqlDriverCompileError/

    puts unless i == 0
    subtests.each_with_index do |subtest, j|
      subtest = language_fixes subtest
      puts unless j == 0
      test_id = "##{i+1}.#{j+1}"
      puts "  #{ARGV.includes?(test_id) ? "pending" : "it"} \"passes on test #{test_id}: #{subtest.gsub("\\", "\\\\").gsub("\"", "\\\"")}\" do"
      if output =~ /err\("(\w+)",\s?"(.+?)"[,)]/
        puts "    expect_raises(RethinkDB::#{$1}, \"#{$2.gsub("\\\\", "\\")}\") do"
        puts "      (#{subtest}).run($reql_conn)"
        puts "    end"
      elsif output =~ /err_regex\("(\w+)",\s?"(.+?)"[,)]/
        puts "    expect_raises(RethinkDB::#{$1}, /#{$2.gsub("\\\\", "\\")}/) do"
        puts "      (#{subtest}).run($reql_conn)"
        puts "    end"
      else
        puts "    result = (#{subtest}).run($reql_conn)"
        puts "    match_reql_output(result) { (#{language_fixes output}) }"
      end
      puts "  end"
    end
  end
end
puts "end"
