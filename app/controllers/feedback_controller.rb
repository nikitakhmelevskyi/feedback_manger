class FeedbackController < ApplicationController
  def create
    validation_result = FeedbackContract.new(contract_options).call(prepared_params)

    if validation_result.success?
      render json: Feedback::Create.call(validation_result.output),
             serializer: FeedbackSerializer,
             adapter: :json
    else
      render_error(validation_result.errors, 422)
    end
  end

  private

  def contract_options
    { experience: Experience.find(params[:experience_id]) }
  end

  def prepared_params
    params.merge(user_ip: request.remote_ip)
  end
end

