class StudentAssignment < ApplicationRecord
  belongs_to :assignment
  belongs_to :student_course

  def student_course
    StudentCourse.find(self.student_course_id)
  end

  def student_sub_assignments
    Assignment.find(self.assignment_id).sub_assignments.map do |sub_assignment|
      return StudentAssignment.find_by(assignment_id: sub_assignment.id)
    end
  end

  def parent
    Assignment.find(self.assignment_id)
  end

end
