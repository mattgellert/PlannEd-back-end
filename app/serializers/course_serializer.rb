class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :credits
end
