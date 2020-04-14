class FeedbackController < ApplicationController
  def create
    validation_result = FeedbackContract.new.call(prepared_params)

    if validation_result.success?
      render json: Feedback::Create.call(validation_result.to_h),
             serializer: FeedbackSerializer,
             adapter: :json,
             status: :created
    else
      render_error(validation_result.errors.to_h, 422)
    end
  end

  private

  def prepared_params
    params.to_unsafe_hash.merge(
      experience: Experience.find(params[:experience_id]),
      user_ip: request.remote_ip
    )
  end
end

