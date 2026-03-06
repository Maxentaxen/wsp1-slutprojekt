require 'debug'
require "awesome_print"
require 'digest'
require 'securerandom'
require 'bcrypt'
require_relative 'models/base_model'
require_relative 'models/movies.rb'
require_relative 'models/users.rb'

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
      p session
      redirect 'index'
    else
      erb(:'login')
    end
  end

  get '/index' do 
    @movies = Movie.get_from_user(session[:user_id])
    @users = Users.get_other_users(session[:user_id])
    p @users
    if @movies 
      erb(:index)
    else
      erb(:add)
    end
  end
  
  get '/add' do
    erb(:"add")
  end

  get '/show/:id' do |id|
    @movieinfo = Movie.getInfo(id)
    @review = Movie.get_review(id, session[:user_id]).first
    ap @review
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

  get '/add-friend' do

  end


  get '/sign-up' do
    erb(:signup)
  end

  post '/signup' do
    ap params
    result = Users.add(params['username'], params['password'], params['repeated_password'])
    if !result
      @incorrect = true
      erb(:signup)
    else
      redirect('/')
    end
  end
end
