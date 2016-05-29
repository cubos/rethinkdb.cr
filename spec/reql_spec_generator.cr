require "yaml"

def yaml_fixes(str)
  str = str.gsub(/(\w+): (.+)\n/) do
    var = $1
    value = $2
    if value =~ /^[^r][a-z]+\(.*\)$/
      "#{var}: \'#{value.gsub("'", "\"")}\'\n"
    else
      "#{var}: \"#{value.gsub("\"", "'")}\"\n"
    end
  end
  str = str.gsub("\\", "\\\\")
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
  str = str.gsub("'", "\"")
  str = str.gsub("[]", "[] of Int32")
  str = str.gsub("{}", "{} of String => Int32")
  str
end

data = YAML.parse(yaml_fixes File.read(ARGV[0]))

puts "describe #{data["desc"].inspect} do"
data["tests"].each_with_index do |test, i|
  if d = test["def"]?
    puts "  #{language_fixes (d["rb"]? || d["cd"]).as_s}"
  else
    subtests = test["rb"]? || test["cd"]?
    next unless subtests
    next if subtests == ""
    subtests = [subtests] unless subtests.raw.is_a? Array
    subtests = subtests.map &.as_s

    output = test["ot"]
    unless output.raw.is_a? String
      output = output["rb"]? || output["cd"]
    end
    output = language_fixes output.as_s
    next if output =~ /ReqlCompileError/ && output =~ /Expected \d+ argument/
    next if output =~ /ReqlDriverCompileError/

    puts unless i == 0
    subtests.each_with_index do |subtest, j|
      subtest = language_fixes subtest
      puts unless j == 0
      test_id = "##{i+1}.#{j+1}"
      puts "  #{ARGV.includes?(test_id) ? "pending" : "it"} \"passes on test #{test_id}\" do"
      if output =~ /err\("(\w+)", "(.+?)",/
        puts "    expect_raises(RethinkDB::#{$1}, \"#{$2.gsub("\\\\", "\\")}\") do"
        puts "      (#{subtest}).run($reql_conn)"
        puts "    end"
      elsif output =~ /err_regex\("(\w+)", "(.+?)",/
        puts "    expect_raises(RethinkDB::#{$1}, /#{$2.gsub("\\\\", "\\")}/) do"
        puts "      (#{subtest}).run($reql_conn)"
        puts "    end"
      else
        puts "    result = (#{subtest}).run($reql_conn)"
        puts "    match_reql_output(result) { #{output} }"
      end
      puts "  end"
    end
  end
end
puts "end"
