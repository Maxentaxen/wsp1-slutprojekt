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
      redirect 'index' 
    else
      redirect 'login'
    end
  end

  get '/login' do
    @showprofile = false
    erb(:login) 
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
    
      
    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    
    
    if bcrypt_db_password == request_plain_password
      session[:user_id] = db_id
      redirect 'index'
    else
      erb(:'login')
    end
  end

  get '/index' do 
    @showprofile = true
    @movies = Movie.get_from_user(session[:user_id])
    @users = Users.get_other_users(session[:user_id])
    @user = session[:user_id]
    if @movies.length > 0
      erb(:index)
    else
      erb(:add)
    end
  end
  
  get '/add' do
    @user = session[:user_id]
    @showprofile = true
    erb(:"add")
  end

  get '/show/:id' do |id|
    @user = session[:user_id]
    @showprofile = true
    @movieinfo = Movie.getInfo(id)
    @review = Movie.get_review(id, session[:user_id]).first
    erb(:"movieinfo")
  end

  post '/add' do
    Movie.add(params, session[:user_id])
    redirect("/")
  end

  post '/delete' do
    Movie.destroy(params['id'])
    redirect("/")
  end

  post '/addfriend/:id' do | id |
    Friends.add_friends(session[:user_id], id.to_i)
    
    redirect "profile/#{id}"
    
  end


  get '/sign-up' do
    erb(:signup)
  end

  post '/signup' do
    result = Users.add(params['username'], params['password'], params['repeated_password'])
    if !result
      @incorrect = true
      erb(:signup)
    else
      redirect('/')
    end
  end

  get '/logout' do
    session.clear
    redirect('/login')
  end

  get '/profile/:id' do |id| 
    @showprofile = true
    @profile = Users.get_user(id).first
    reviews = Movie.get_reviews_from_user(id)
    @user = session
    @friends = Friends.check_friendship_status(session[:user_id], id.to_i)
    erb(:profile)
  end
end
