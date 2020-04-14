class ResponseSerializer < BaseSerializer
  attributes :id, :answer

  has_one :question
end
