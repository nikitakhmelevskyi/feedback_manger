class Feedback < ActiveRecord::Base
  belongs_to :experience
  has_many :responses
end
