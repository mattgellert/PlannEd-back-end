class Event < ApplicationRecord
  has_many :student_course_events
  has_many :student_courses, through: :student_course_events
  has_many :student_assignment_events
  has_many :student_assignments, through: :student_assignment_events
  has_many :stud_course_comp_events
  has_many :student_course_component, through: :stud_course_comp_events

end
