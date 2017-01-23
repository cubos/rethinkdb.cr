require "./spec_helper"

describe RethinkDB do
  it "successfuly connects to the database" do
    conn = Fixtures::TestDB.conn
  end

  it "rejects an invalid auth_key" do
    expect_raises(RethinkDB::ReqlDriverError, "ERROR: Incorrect authorization key.") do
      r.connect({host: Fixtures::TestDB.host, auth_key: "owenfvoraewugbjbkv"})
    end
    expect_raises(RethinkDB::ReqlDriverError, "ERROR: Incorrect authorization key.") do
      r.connect({host: Fixtures::TestDB.host, auth_key: "ԱԲԳԴԵԶԷԸԹԺԻԼԽԾ"})
    end
  end

  it "works" do
    # conn = r.connect({host: "rethinkdb"})
    # r.expr(3).run(conn).should eq 3
    # r.expr([1, 2, "hello"]).run(conn).should eq [1, 2, "hello"]
    # r.now.run(conn).as_time.epoch.should be_close Time.now.epoch, 5
    #
    # cur = r.range(1, 5).run(conn)
    # p cur.to_a
  end
end
