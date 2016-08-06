require_relative "../config/environment.rb"

require "pry"

class Student

attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students
    (id INTEGER PRIMARY KEY,
    name TEXT,
    grade TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end 

  def save
    if id == nil
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      self
    else
      self.update
    end
  end

  def update
    if id != nil
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else 
      self.save
    end
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    new_student = self.new(row[0], row[1], row[2])
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    new_student = (DB[:conn].execute(sql, name)[0])
    self.new_from_db(new_student)
  end

end
