require 'debug'
require "awesome_print"
require 'digest'
require 'securerandom'
require 'bcrypt'

require_relative 'models/base_model'
require_relative 'models/movies.rb'
require_relative 'models/users.rb'
require_relative 'models/friends.rb'



class App < Sinatra::Base
  login_attempts = [1]
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


  # Skickar dig till index-sidan om du är inloggad. Annars skickas de till inloggningssidan
  get '/' do
    if session[:user_id]
      redirect 'index' 
    else
      redirect '/users/login'
    end
  end
  

  # Loginsidan. @showprofile används i layout.erb för att bestämma om en viss länk ska visas
  get '/users/login' do
    @showprofile = false
    erb(:'/users/login') 
  end
  
  # Själva inloggningslogiken. Om man gör 5 felaktiga inloggningsförsök kommer "login"-knappen att försvinna. Den kontrollerar ditt inskrivna lösenord mot det hashade lösenordet i databasen
  post '/users/login' do
    @failed = false
    request_username = params[:username]
    request_plain_password = params[:password]
    
    @user = Users.get_user_from_name(request_username)
    unless @user
      status 401
      redirect 'users/sign-up'
    end
    
    db_id = @user['id'].to_i
    db_password_hashed = @user['password'].to_s
    
    
    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    
    ip = request.ip
    if bcrypt_db_password == request_plain_password
      session[:user_id] = db_id
      ap session
      redirect 'index'
    else
      time = Time.now
      p login_attempts.class
      login_attempts << {
        'ip' => ip,
        'time' => time
      }
      p "Login attempt from #{ip} failed."
      if login_attempts.length >= 6
        p login_attempts
        p "5 failed passwords. Blocking user"
        @failed = true
      end
      erb(:'/users/login')
    end
  end
  # Indexsidan hämtar dina filmer och alla andra användare. Ifall du inte har några filmer sparade kommer du skickas till sidan för att lägga till en film istället
  get '/index' do 
    @showprofile = true
    @movies = Movie.get_from_user(session[:user_id])
    @users = Users.get_other_users(session[:user_id])
    @user = session[:user_id]
    if @movies.length > 0
      erb(:'/movies/index')
    else
      erb(:'/movies/add')
    end
  end
  # Formulär för att lägga till en film
  get '/movies/add' do
    @user = session[:user_id]
    @showprofile = true
    erb(:"/movies/add")
  end
  # Visar information om en film samt din recension
  get '/movies/show/:id' do |id|
    @user = session[:user_id]
    @showprofile = true
    @movieinfo = Movie.getInfo(id)
    @review = Movie.get_review(id, session[:user_id]).first
    erb(:"/movies/movieinfo")
  end
  # Lägger till en film i ditt namn i movies och user_watched
  post '/movies/add' do
    Movie.add(params, session[:user_id])
    redirect("/")
  end
  # Tar bort en film
  post '/movies/delete' do
    Movie.destroy(params['id'])
    redirect("/")
  end

  # Lägger till en annan användare som vän
  post '/users/addfriend/:id' do | id |
    Friends.add_friends(session[:user_id], id.to_i)
    
    redirect "profile/#{id}"
  end

  # Formulär för att skapa ett konto (användarnamn och lösenord)
  get '/users/sign-up' do
    erb(:'/users/signup')
  end

  # Lägger till en ny användare i databasen om lösenordet och repeated_password stämmer överrens
  post '/users/signup' do
    result = Users.add(params['username'], params['password'], params['repeated_password'])
    if !result
      @incorrect = true
      erb(:'/users/signup')
    else
      redirect('/')
    end
  end

  # Visar en annan användares information
  get '/users/profile/:id' do |id| 
    @showprofile = true
    @profile = Users.get_user(id).first
    @reviews = Movie.get_reviews_from_user(id)
    @user = session['user_id']
    @friends = Friends.check_friendship_status(session[:user_id], id.to_i)
    erb(:'/users/profile')
  end

  # Tar bort en vän :(
  post 'users/breakup/:id' do | id |
    Friends.breakup(session[:user_id], id.to_i)
    redirect '/'
  end

end
