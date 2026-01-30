require 'debug'
require "awesome_print"

class App < Sinatra::Base

    def db
      return @db if @db

      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end
    
    get '/' do
      @movies = db.execute('SELECT name, poster, id, watched FROM movies ORDER BY watched')
      @watchedmovies, @unwatchedmovies = @movies.partition { |item| item["watched"] == 1 } 
      erb(:"index") 
    end

    get '/index' do 
      erb(:'index')
    end
    
    get '/add' do
      erb(:"add")
    end

    get '/show/:id' do |id|
      @movieinfo = db.execute('SELECT name, year, imdb_rating, runtime, watched, score, note, GROUP_CONCAT(DISTINCT genre_name) as genres, GROUP_CONCAT(DISTINCT service_name) as services, poster, movies.id FROM movies
                              INNER JOIN movies_genres 
                                ON movies.id = movies_genres.movie_id
                              INNER JOIN genres
                                ON movies_genres.genre_id = genres.genre_id
                              INNER JOIN movies_services
                                ON movies.id = movies_services.movie_id
                              INNER JOIN services
                                ON movies_services.service_id = services.service_id 
                              WHERE movies.id = ?
                            GROUP BY movies.id ', id).first
      erb(:"movieinfo")
    end

    post '/add' do
      movieParams = [params['name'], params['year'].to_i, params['imdb_rating'], params['runtime'], params['poster']]
      db.execute('INSERT INTO movies (name, year, imdb_rating, runtime, watched, score, note, poster) 
                              VALUES (?, ?, ?, ?, 0, "", "", ?)', movieParams)
      id = db.execute("SELECT id FROM movies where name=?", params['name']).first.values
      params['genre'].each do | genreName |
        id_database_params = [id, genreName.to_i]
        p id_database_params
        db.execute("INSERT INTO movies_genres (movie_id, genre_id) VALUES (?,?)", id_database_params)
      end
      params['service'].each do |service|
        service_db_params = [id, service]
        db.execute("INSERT INTO movies_services (movie_id, service_id) VALUES (?,?)", service_db_params)
      end
      redirect("/")
    end

    post '/delete' do
      id = params['id']
      db.execute("DELETE FROM movies WHERE id = ?", id)
      db.execute("DELETE FROM movies_genres WHERE movie_id = ?", id)
      db.execute("DELETE FROM movies_services WHERE movie_id = ?", id)
      redirect("/")
    end

    get '/review/:id' do | id |
      @movieinfo = db.execute('SELECT name, year, imdb_rating, runtime, watched, score, note, GROUP_CONCAT(DISTINCT genre_name) as genres, GROUP_CONCAT(DISTINCT service_name) as services, poster, movies.id FROM movies
                              INNER JOIN movies_genres 
                                ON movies.id = movies_genres.movie_id
                              INNER JOIN genres
                                ON movies_genres.genre_id = genres.genre_id
                              INNER JOIN movies_services
                                ON movies.id = movies_services.movie_id
                              INNER JOIN services
                                ON movies_services.service_id = services.service_id 
                              WHERE movies.id = ? 
                            GROUP BY movies.id ', id).first
      erb(:"review")
    end

    post '/review/:id' do | id |
      updateParams = [params['score'], params['note'], id]
      db.execute('UPDATE  movies SET 
                    watched = 1,
                    score = ?, 
                    note = ? 
                  WHERE id = ?', updateParams)
      redirect("/")
    end
end
