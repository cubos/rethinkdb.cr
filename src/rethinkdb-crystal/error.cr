module RethinkDB
  class ReqlDriverError < Exception
  end

  class ReqlClientError < Exception
  end

  class ReqlCompileError < Exception
  end

  class ReqlRunTimeError < Exception
  end

  class ReqlQueryLogicError < Exception
  end

  class ReqlUserError < Exception
  end
end
