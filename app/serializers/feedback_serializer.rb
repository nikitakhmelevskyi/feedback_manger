class FeedbackSerializer < BaseSerializer
  attributes :id, :rating

  has_one :experience
  has_many :responses
end
