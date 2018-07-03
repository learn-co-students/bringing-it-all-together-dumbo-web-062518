require 'pry'

class Dog

attr_accessor :id, :name, :breed

def initialize(name:, breed:, id:nil)
  @id = id
  @name = name
  @breed = breed
end

#CLASS METHODS
def self.create_table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
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

def self.create(hash)
  dog = Dog.new(hash)
  dog.save
  dog
end

def self.find_by_id(id)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
  SQL
  result = DB[:conn].execute(sql, id)[0]
  Dog.new(name: result[1], breed: result[2], id: result[0])
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
  SQL
  result = DB[:conn].execute(sql, name)[0]
  Dog.new(name: result[1], breed: result[2], id: result[0])
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if dog.empty?
    dog = self.create(name: name, breed: breed)
  else
    doggy_data = dog[0]
    dog = Dog.new(name:doggy_data[1], breed:doggy_data[2], id:doggy_data[0])
  end
  dog
end

def self.new_from_db(row)
  new_dog = self.new(name: row[1], breed: row[2], id: row[0])
end

#INSTANCE METHODS
def update
sql = <<-SQL
  UPDATE dogs
  SET name=?, breed=?
  WHERE id=?
SQL
DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def save
if self.id
  self.update
else
  sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end
end





end
