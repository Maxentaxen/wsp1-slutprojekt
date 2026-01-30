require 'sqlite3'
require_relative '../config'

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
    db.execute('DROP TABLE IF EXISTS services')
    db.execute('DROP TABLE IF EXISTS movies_services')




  end

  def self.create_tables
    db.execute('CREATE TABLE movies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                year INTEGER,
                imdb_rating TEXT,
                runtime INTEGER,
                watched BIT,
                score TEXT,
                note TEXT, 
                poster TEXT)')

    db.execute('CREATE TABLE genres (
                  genre_id INTEGER PRIMARY KEY AUTOINCREMENT,
                  genre_name TEXT NOT NULL)')
    
    db.execute('CREATE TABLE movies_genres (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                movie_id INTEGER,
                genre_id INTEGER)')

    db.execute('CREATE TABLE services (
                service_id INTEGER PRIMARY KEY AUTOINCREMENT,
                service_name TEXT NOT NULL)')
    
    db.execute('CREATE TABLE movies_services (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                movie_id INTEGER,
                service_id INTEGER)')

  end

  def self.populate_tables
    db.execute('INSERT INTO movies (name, year, imdb_rating, runtime, watched, score, note, poster) VALUES ("Oppenheimer", 2023, "8.3", 180, 0, "","", "https://www.hollywoodreporter.com/wp-content/uploads/2022/07/Oppenheimer-Movie-Poster-Universal-Publicity-EMBED-2022-.jpg?w=1000")') 

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
    db.execute('INSERT INTO services (service_name) VALUES ("Netflix")')
    db.execute('INSERT INTO services (service_name) VALUES ("Disney+")')
    db.execute('INSERT INTO movies_services (movie_id, service_id) VALUES (1,1)')
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