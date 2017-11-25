class Assignment < ApplicationRecord
  belongs_to :course
  has_many :student_assignments
  has_many :sub_assignmnets, class_name: "Assignment", foreign_key: "primary_assignment_id"
  belongs_to :primary_assignment, class_name: "Assignment", optional: true

  def sub_assignments
    @sub_assignments = Assignment.all.where(primary_assignment_id: self.id)
    return @sub_assignments
  end

end
