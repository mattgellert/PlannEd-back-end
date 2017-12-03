class StudentAssignmentEvent < ApplicationRecord
  belongs_to :event
  belongs_to :student_assignment
end
