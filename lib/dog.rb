class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash)
    @id = dog_hash[:id]
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS dogs;
      SQL
      DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
      dog_hash = {}
      dog_hash[:id] = row[0]
      dog_hash[:name] = row[1]
      dog_hash[:breed] = row[2]
      new_dog = self.new(dog_hash)
      new_dog
    end

    def save
      # if self.id
      #   self.update
      # else
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
      # end
    end

    def update
      sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(dog_hash)
      new_dog = Dog.new(dog_hash)
      new_dog.save
      new_dog
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?;
        SQL
        result = DB[:conn].execute(sql, id)[0]
        found_dog = self.new_from_db(result)
        found_dog
      end

      def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?;
        SQL
        result = DB[:conn].execute(sql, name)[0]
        found_dog = self.new_from_db(result)
        found_dog
      end

      def self.find_or_create_by(dog_hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog_hash[:name], dog_hash[:breed])
          if !dog.empty?
            dog_data = dog[0]
            dog = self.new_from_db(dog_data)
          else
            dog = self.create(dog_hash)
          end
        dog
      end
end
