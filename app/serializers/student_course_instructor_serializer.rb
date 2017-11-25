class StudentCourseInstructorSerializer < ActiveModel::Serializer
  attributes :id
  has_one :student_course
  has_one :instructor
end
