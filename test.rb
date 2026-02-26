require 'bcrypt'

password = BCrypt::Password.create("123")
p password

