require_relative 'base_model'
require 'bcrypt'
class Users < BaseModel


  #
  # Hämtar information om en användare från användarnamnet
  #
  # @param [str] username Användarnamnet man vill hämta information om
  #
  # @return [hash] Användarens rad i users-tabellen
  #
  def self.get_user_from_name(username)
    db.execute('SELECT * FROM users WHERE username=?', username).first
  end
  
  #
  # Hämtar alla användare förutom den givna
  #
  # @param [int] id ID hos användaren man vill exkludera
  #
  # @return [array] id och användarnamn för alla andra användare
  #
  def self.get_other_users(id)
    db.execute('SELECT id, username FROM users WHERE id != ?', id)
  end

  
  #
  # Hämtar information om en viss användare från dess id
  #
  # @param [int] id ID:t man vill komma åt
  #
  # @return [hash] Allting om användaren
  #
  def self.get_user(id)
    db.execute('SELECT * FROM users WHERE id = ?', id)
  end

  
  #
  # Lägg till en användare i databasen
  #
  # @param [str] username Användarnamnet som den nya användaren ska ha
  # @param [str] password Lösenordet man skriver in
  # @param [str] repeated_password Lösenordet man repeterar
  #
  # @return [bool] False om lösenorden inte matchar, annars ingenting
  #
  def self.add(username, password, repeated_password)
    if password != repeated_password
      false
    else
      hashed_password = BCrypt::Password.create(password).to_s
      db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, hashed_password])
    end
  end


end