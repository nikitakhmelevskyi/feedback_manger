class Experience < ActiveRecord::Base
  has_many :feedback
  has_many :questions
end
