class StudentAssignmentSerializer < ActiveModel::Serializer
  attributes :id, :completed
  has_one :assignment
  has_one :student
end
