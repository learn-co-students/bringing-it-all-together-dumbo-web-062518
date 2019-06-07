require 'pry'

class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:, breed:, id: nil)
		@name = name	
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs(
				id INTEGER PRIMARY KEY,
				breed TEXT,
				name TEXT
			)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL 
		 	DROP TABLE IF EXISTS dogs
		 SQL
		 DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL 
			INSERT INTO dogs (name, breed) VALUES (?, ?)
		SQL
		# binding.pry
		DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		# binding.pry
		return self
	end

	def self.create(name:, breed:)
		dog = Dog.new(name: name, breed: breed)
		dog.save
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL 
			SELECT * FROM dogs WHERE id = ?
		SQL
		result = DB[:conn].execute(sql, id).first
		self.new_from_db(result)
	end

	def self.new_from_db(array)
		dog = Dog.new(name: array[1], breed: array[2], id: array[0])
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs WHERE name = ?
		SQL
		result = DB[:conn].execute(sql, name).first
		self.new_from_db(result)
	end

	def update
		sql = <<-SQL 
			UPDATE dogs SET name = ?, breed = ? WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def self.find_or_create_by(name:, breed:)
		new_dog = Dog.new(name: name, breed: breed)
		# binding.pry
		sql = <<-SQL 
			SELECT * FROM dogs WHERE name = ? AND breed = ?
		SQL
		result = DB[:conn].execute(sql, new_dog.name, new_dog.breed).first
		# binding.pry
		if result
			# binding.pry
			return self.new_from_db(result)
		else 
			new_dog.save
		end 
	end
end


