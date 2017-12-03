class StudentCourseComponent < ApplicationRecord
  belongs_to :student_course

  def course_parent
    Course.find(StudentCourse.find(self.student_course_id).id)
  end

end
