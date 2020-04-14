class Feedback::Create
  attr_reader :params

  def self.call(params)
    new(params).call
  end

  private

  def initialize(params)
    @params = params
  end

  def call
    create_feedback_with_responses

    Experience::RatingRecalculationJob.perform_async(params[:experience].id)

    feedback
  end

  def create_feedback_with_responses
    Feedback.transaction do
      feedback = Feedback.create!(
        experience: params[:experience],
        rating: params[:rating]
      )

      params[:responses].each do |response|
        Response.create(
          feedback: feedback,
          question_id: response[:question_id],
          answer: response[:answer]
        )
      end
    end
  end
end
