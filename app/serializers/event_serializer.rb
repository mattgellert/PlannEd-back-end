class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :startDate, :endDate
end
