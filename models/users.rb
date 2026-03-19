require_relative 'base_model'
require 'bcrypt'
class Users < BaseModel

  def self.get_other_users(id)
    db.execute('SELECT id, username FROM users WHERE id != ?', id)
  end

  def self.get_user(id)
    db.execute('SELECT * FROM users WHERE id = ?', id)
  end
  def self.add(username, password, repeated_password)
    if password != repeated_password
      false
    else
      hashed_password = BCrypt::Password.create(password).to_s
      db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, hashed_password])
    end
  end
end