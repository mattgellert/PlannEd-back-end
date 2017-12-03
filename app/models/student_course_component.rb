class StudentCourseComponent < ApplicationRecord
  belongs_to :student_course

  has_many :stud_course_comp_events
  has_many :events, through: :stud_course_comp_events

  def course_parent
    Course.find(StudentCourse.find(self.student_course_id).course_id)
  end

end
