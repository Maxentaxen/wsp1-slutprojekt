require_relative 'base_model'


class Movie < BaseModel

  def self.all()
    db.execute('SELECT * FROM movies')
  end

  def self.get_from_user(id)
    @movie_ids = db.execute('SELECT movie_id FROM user_watched WHERE user_id = ?', id).map(&:values).flatten

    if !@movie_ids.nil?
      placeholders = (['?'] * @movie_ids.length).join(',')
      sql = "SELECT name, poster, id FROM movies WHERE id IN (#{placeholders})"
      @movies = db.execute(sql, @movie_ids)
      @movies
    else
      nil
    end
  end

  def self.add(params, user_id)

    movienames = db.execute('SELECT name FROM movies').map(&:values).flatten
    movieParams = [params['name'], params['year'].to_i, params['imdb_rating'], params['runtime'], params['poster']]
    if !movienames.include?(params['name'])
      db.execute('INSERT INTO movies (name, year, imdb_rating, runtime, poster) 
          VALUES (?, ?, ?, ?, ?)', movieParams)
      id = db.execute("SELECT id FROM movies where name=?", params['name']).first.values

      params['genre'].each do |genre_id|
        id_database_params = [id, genre_id.to_i]
        db.execute('INSERT INTO movies_genres (movie_id, genre_id) values (?, ?)', id_database_params)
      end
    end

    userInfo = db.execute('SELECT movie_id FROM user_watched WHERE user_id = ?', user_id).map(&:values).flatten

    if userInfo
      if !userInfo.include?(id)
        db.execute('INSERT INTO user_watched (user_id, movie_id, score, review) VALUES (?, ?, ?, ?)', [user_id, id, params['score'], params['note']])
      end
    end

  end

  def self.getInfo(movie_id)
    db.execute('SELECT name, year, imdb_rating, runtime, GROUP_CONCAT(DISTINCT genre_name) as genres, poster, movies.id FROM movies
                            INNER JOIN movies_genres 
                              ON movies.id = movies_genres.movie_id
                            INNER JOIN genres
                              ON movies_genres.genre_id = genres.genre_id 
                            WHERE movies.id = ?
                          GROUP BY movies.id ', movie_id).first
    
  end

  def self.get_review(movie_id, user_id)
    db.execute('SELECT score, review FROM user_watched WHERE user_id = ? AND movie_id = ?', [user_id, movie_id])
  end


  def self.destroy(id)
    db.execute('DELETE FROM movies WHERE id = ?', id)
    db.execute('DELETE FROM movies_genres WHERE movie_id = ?', id)
  end
end


# get all from user id

# add

# show

# update

# destroy
