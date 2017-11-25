class Course < ApplicationRecord
  has_many :assignments
  has_many :student_courses

end
