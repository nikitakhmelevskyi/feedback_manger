class Feedback::Create
  attr_reader :params

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    # lock experience record
    experience.with_lock do
      # this block is called within a transaction
      feedback = create_feedback_with_responses

      # releases the lock by calling update!
      Experience::RatingUpdater.call(experience)

      feedback
    end
  end

  private

  def experience
    params[:experience]
  end

  def create_feedback_with_responses
    Feedback.transaction do
      feedback = Feedback.create!(
        experience: experience,
        rating: params[:rating]
      )

      params[:responses].each do |response|
        Response.create(
          feedback: feedback,
          question_id: response[:question_id],
          answer: response[:answer]
        )
      end

      feedback
    end
  end
end
