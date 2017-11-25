class Instructor < ApplicationRecord
  has_many :student_course_instructors
  has_many :student_courses, through: :student_course_instructors
end
