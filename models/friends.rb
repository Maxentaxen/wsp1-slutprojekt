class Friends < BaseModel

  def self.check_friendship_status(user_1, user_2)
    entries_1 = db.execute('SELECT * FROM friends WHERE user_1 = ?', user_1)
    entries_2 = db.execute('SELECT * FROM friends WHERE user_1 = ?', user_2)
    entries_1.each do | entry |
      if entry['user_2'] == user_2.to_i
        return true
      end
    end
    entries_2.each do | entry | 
      if entry['user_2'] == user_1
        return true
      end
    end
    false
  end


  def self.add_friends(user_1, user_2)
    db.execute('INSERT INTO friends (user_1, user_2) VALUES (?, ?)', [user_1, user_2])
  end


  def self.breakup(user_1, user_2)
    # remove the entry from the table
  end
end