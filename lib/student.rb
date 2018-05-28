require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id
      self.update
    else 
    sql = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, @name, @grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(id, name, grade)
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @grade, @id)
  end
end
