class StudCourseCompEvent < ApplicationRecord
  belongs_to :event
  belongs_to :student_course_component
end
