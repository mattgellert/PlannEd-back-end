class StudentCourseEventSerializer < ActiveModel::Serializer
  attributes :id
  has_one :event
  has_one :student_course
end
