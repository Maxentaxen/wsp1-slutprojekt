require 'sqlite3'
require_relative '../config'
require 'bcrypt'
class Seeder

  def self.seed!
    puts "Using db file: #{DB_PATH}"
    puts "🧹 Dropping old tables..."
    drop_tables
    puts "🧱 Creating tables..."
    create_tables
    puts "🍎 Populating tables..."
    populate_tables
    puts "✅ Done seeding the database!"
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS movies')
    db.execute('DROP TABLE IF EXISTS genres')
    db.execute('DROP TABLE IF EXISTS movies_genres')
    db.execute('DROP TABLE IF EXISTS user_watched')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS friends')




  end

  def self.create_tables
    db.execute('CREATE TABLE movies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                year INTEGER,
                imdb_rating TEXT,
                runtime INTEGER,
                poster TEXT)')

    db.execute('CREATE TABLE genres (
                  genre_id INTEGER PRIMARY KEY AUTOINCREMENT,
                  genre_name TEXT NOT NULL)')
    
    db.execute('CREATE TABLE movies_genres (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                movie_id INTEGER,
                genre_id INTEGER)')

    db.execute('CREATE TABLE user_watched (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                movie_id INTEGER,
                score INTEGER,
                review TEXT)')

    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                password TEXT NOT NULL,
                godmode BOOL)')

    db.execute('CREATE TABLE friends (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_1,
                user_2)')

  end

  def self.populate_tables
    db.execute('INSERT INTO movies (name, year, imdb_rating, runtime, poster) VALUES ("Oppenheimer", 2023, "8.3", 180, "https://www.hollywoodreporter.com/wp-content/uploads/2022/07/Oppenheimer-Movie-Poster-Universal-Publicity-EMBED-2022-.jpg?w=1000")') 

    db.execute('INSERT INTO genres (genre_name) VALUES ("Thriller")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Biography")')  
    db.execute('INSERT INTO genres (genre_name) VALUES ("Comedy")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Romance")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Horror")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Adventure")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Action")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Documentary")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Fantasy")')      
    db.execute('INSERT INTO genres (genre_name) VALUES ("Drama")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Science Fiction")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Animation")')
    db.execute('INSERT INTO genres (genre_name) VALUES ("Musical")')    
    

  
    db.execute('INSERT INTO movies_genres (movie_id, genre_id) VALUES (1, 1)') 
    db.execute('INSERT INTO movies_genres (movie_id, genre_id) VALUES (1, 2)') 

    hashed_password = BCrypt::Password.create("Password123").to_s
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Maxentaxen", hashed_password])

    anton_lösnord = BCrypt::Password.create("Duvermongo").to_s
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Duvermongo", anton_lösnord])

    hilda_lösenord = BCrypt::Password.create('H1mb2rg3r4').to_s
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Alfawolfshrexylover69", hilda_lösenord])

    db.execute('INSERT INTO user_watched (user_id, movie_id, score, review) VALUES (1, 1, 10, "Bleh")')
    
    db.execute('INSERT INTO friends (user_1, user_2) VALUES (1,2)')
  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

end

Seeder.seed!