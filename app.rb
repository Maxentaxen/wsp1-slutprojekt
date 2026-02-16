require 'debug'
require "awesome_print"
require 'digest'
require 'securerandom'
require 'bcrypt'



class App < Sinatra::Base

    def db
      return @db if @db

      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end
    
    get '/' do
      if session[:user_id]
        @movies = db.execute('SELECT name, poster, id FROM movies ')
        erb(:"index") 
      else
        erb(:"login")
      end
    end


    post '/login' do
      request_username = params[:username]
      request_plain_password = params[:password]

      @user = db.execute('SELECT * FROM users WHERE username=?', [request_username]).first

      unless @user
        status 401
        redirect 'unauthorized'
      end

      db_id = @user['id'].to_i
      db_password_hashed = @user['password'].to_s

      begin
        bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
        
        if bcrypt_db_password == request_plain_password
          session[:user_id] = db_id
          redirect 'index'
        else
          status 401
          redirect 'unauthorized'
        end
      rescue BCrypt::Errors::InvalidHash => e
        status 401
        redirect 'unauthorized'
      end
    end

    get '/index' do 
      erb(:'index')
    end
    
    get '/add' do
      erb(:"add")
    end

    get '/show/:id' do |id|
      @movieinfo = db.execute('SELECT name, year, imdb_rating, runtime, GROUP_CONCAT(DISTINCT genre_name) as genres, poster, movies.id FROM movies
                              INNER JOIN movies_genres 
                                ON movies.id = movies_genres.movie_id
                              INNER JOIN genres
                                ON movies_genres.genre_id = genres.genre_id 
                              WHERE movies.id = ?
                            GROUP BY movies.id ', id).first
      erb(:"movieinfo")
    end

    post '/add' do
      ap params
      movienames = db.execute('SELECT name FROM movies').first.values
      ap movienames
      movieParams = [params['name'], params['year'].to_i, params['imdb_rating'], params['runtime'], params['poster']]
      if !movienames.include?(params['name'])
        db.execute('INSERT INTO movies (name, year, imdb_rating, runtime, poster) 
            VALUES (?, ?, ?, ?, ?)', movieParams)
        id = db.execute("SELECT id FROM movies where name=?", params['name']).first.values
        
        params['genres'].each do | genreName |
          id_database_params = [id, genreName.to_i]
          p id_database_params
          db.execute("INSERT INTO movies_genres (movie_id, genre_id) VALUES (?,?)", id_database_params)
        end
      end
      redirect("/")
    end

    post '/delete' do
      id = params['id']
      db.execute("DELETE FROM movies WHERE id = ?", id)
      db.execute("DELETE FROM movies_genres WHERE movie_id = ?", id)
      redirect("/")
    end

    get '/review/:id' do | id |
      @movieinfo = db.execute('SELECT name, year, imdb_rating, runtime, GROUP_CONCAT(DISTINCT genre_name) as genres, poster, movies.id FROM movies
                              INNER JOIN movies_genres 
                                ON movies.id = movies_genres.movie_id
                              INNER JOIN genres
                                ON movies_genres.genre_id = genres.genre_id
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
