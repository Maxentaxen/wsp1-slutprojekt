require_relative 'base_model'
require 'ap'

class Movie < BaseModel




  #
  # Listar all info om alla filmer
  #
  # @return [array] Array full med all data från movies-tabellen
  #
  def self.all()
    db.execute('SELECT * FROM movies')
  end

  #
  # Hämtar alla filmer som en viss användare har recenscerat
  #
  # @param [int] id Användarens id
  #
  # @return [array] Array med namn, id och posterlänk för alla filmer som användaren har recenscerat
  #
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

  
  #
  # Lägger till en ny film i databasen
  #
  # @param [hash] params Informationen för filmen som man vill slänga in
  # @param [int] user_id Användaren som lägger in det (för att lägga in i user_watched)
  #
  # @return [none] description
  #
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

  #
  # Hämtar all information om en viss film
  #
  # @param [int] movie_id ID för filmen man vill hämta information om
  #
  # @return [hash] Allting om filmen
  #
  def self.getInfo(movie_id)
    db.execute('SELECT name, year, imdb_rating, runtime, GROUP_CONCAT(DISTINCT genre_name) as genres, poster, movies.id FROM movies
                            INNER JOIN movies_genres 
                              ON movies.id = movies_genres.movie_id
                            INNER JOIN genres
                              ON movies_genres.genre_id = genres.genre_id 
                            WHERE movies.id = ?
                          GROUP BY movies.id ', movie_id).first
    
  end

  #
  # Hämtar en recension utifrån film-id och användare
  #
  # @param [int] movie_id filmens ID
  # @param [int] user_id användarens ID
  #
  # @return [hash] informationen om användarens recension på filmen 
  #
  def self.get_review(movie_id, user_id)
    db.execute('SELECT score, review FROM user_watched WHERE user_id = ? AND movie_id = ?', [user_id, movie_id])
  end


  #
  # Tar bort en recension
  #
  # @param [int] user Användarens ID
  # @param [int] movie Filmens ID
  #
  # @return [none] 
  #
  def self.destroy(user, movie) 
    db.execute('DELETE FROM user_watched WHERE movie_id = ? AND user_id = ?', [movie, user])
  end

  #
  # Hämtar alla recensioner från en användare
  #
  # @param [int] id användarens ID
  #
  # @return [array] En array med alla användarens recensioner
  #
  def self.get_reviews_from_user(id)
    reviews = db.execute('SELECT movie_id, score, review FROM user_watched WHERE user_id = ?', id)
    movie_ids = []
    reviews.each do | item |
      movie_ids << item['movie_id']
    end
    placeholders = (['?'] * reviews.length).join(',')
    sql = "SELECT name FROM movies WHERE id IN (#{placeholders})"
    movieNames = db.execute(sql, movie_ids)
    moviePosters = db.execute("SELECT poster FROM movies WHERE id IN (#{placeholders})", movie_ids)
    output = []
    i = 0
    while i < reviews.length
      output << {
        'name' => movieNames[i].values.first,
        'review' => reviews[i]['review'],
        'score' => reviews[i]['score'],
        'poster' => moviePosters[i].values.first
      }
      i += 1
    end
    output
  end

  def self.edit_review(id, movie, params)
    db.execute('UPDATE user_watched SET score = ?, review = ? WHERE movie_id == ? AND user_id == ?', [params['score'], params['review'], movie, id])

  end
end
