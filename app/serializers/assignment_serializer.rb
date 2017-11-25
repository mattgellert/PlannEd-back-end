class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :deliverables, :due_date, :parent_id
  has_one :course
end
