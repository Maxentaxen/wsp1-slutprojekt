require_relative 'base_model.rb'

class Friends < BaseModel

  #
  # Kollar vänskapsstatus mellan två användare
  #
  # @param [int] user_1 ID:t för användare 1
  # @param [int] user_2 ID:t för användare 2
  #
  # @return [int] 1 ifall de är vänner, 0 annars
  #
  def self.check_friendship_status(user_1, user_2)
    entries_1 = db.execute('SELECT * FROM friends WHERE user_1 = ?', user_1)
    entries_2 = db.execute('SELECT * FROM friends WHERE user_1 = ?', user_2)
    entries_1.each do | entry |
      if entry['user_2'] == user_2.to_i
        return 1
      end
    end
    entries_2.each do | entry | 
      if entry['user_2'] == user_1
        return 1
      end
    end
    0
  end


  #
  # Lägger till ett par med vänner i databasen
  #
  # @param [int] user_1 ID:t hos användare 1
  # @param [int] user_2 ID:t hos användare 2
  #
  # @return [none] description
  #
  def self.add_friends(user_1, user_2)
    db.execute('INSERT INTO friends (user_1, user_2) VALUES (?, ?)', [user_1, user_2])
  end


  #
  # Tar bort en vänskap från databasen, testar båda hållen för att hitta databasmatcher
  #
  # @param [Type] user_1 ID:t hos användare 1
  # @param [Type] user_2 ID:t hos användare 2
  #
  # @return [none] description
  #
  def self.breakup(user_1, user_2)
    p 'Breaking up...'
    db.execute('DELETE FROM friends WHERE user_1 = ? AND user_2 = ?', [user_1, user_2])
    db.execute('DELETE FROM friends WHERE user_1 = ? AND user_2 = ?', [user_2, user_1])
  end

end