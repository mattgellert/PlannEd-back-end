class StudentCourseInstructor < ApplicationRecord
  belongs_to :student_course
  belongs_to :instructor
end
