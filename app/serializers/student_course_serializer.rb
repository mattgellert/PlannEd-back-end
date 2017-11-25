class StudentCourseSerializer < ActiveModel::Serializer
  attributes :id, :completed
  has_one :course
  has_one :student
end
