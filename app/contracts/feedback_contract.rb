class FeedbackContract < Dry::Validation::Contract
  params do
    required(:experience)
    required(:rating).value(:integer, gteq?: 1, lteq?: 5)

    required(:user_ip).value(:string)

    required(:responses).array(:hash) do
      required(:question_id).value(:integer)
      required(:answer).value(:string)
    end
  end

  rule(:user_ip) do
    experience = values[:experience]

    if experience.present? && experience.feedback.exists?(user_ip: value)
      key.failure('this user has already left a feedback for this experience')
    end
  end
end
