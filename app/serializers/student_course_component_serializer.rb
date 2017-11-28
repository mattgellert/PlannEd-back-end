class StudentCourseComponentSerializer < ActiveModel::Serializer
  attributes :id, :title, :section, :time_start, :time_end, :pattern, :facility_descr, :facility_descr_short
  has_one :student_course
end
