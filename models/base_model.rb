class BaseModel

  def self.db
    return @db if @db_id

    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    @db

  end
  
end