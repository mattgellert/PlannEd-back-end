class StudentCourse < ApplicationRecord
  belongs_to :course
  belongs_to :student
  has_many :student_course_instructors
  has_many :instructors, through: :student_course_instructors
  has_many :student_course_components # no way to access from front-end currently?

  has_many :student_course_events
  has_many :events, through: :student_course_events

  def student_assignments
    StudentAssignment.all.where(student_course_id: self.id)
  end

  def parent
    Course.find(self.course_id)
  end

end
