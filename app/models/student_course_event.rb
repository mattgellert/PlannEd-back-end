class StudentCourseEvent < ApplicationRecord
  belongs_to :event
  belongs_to :student_course
end
