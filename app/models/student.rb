class Student < ApplicationRecord
  has_many :student_courses
  has_many :student_assignments

  def student_courses
    student_courses = StudentCourse.all.where(student_id: self.id)
  end

end
