class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |e|
    render_404(e.model)
  end

  def render_404(model)
    message = I18n.t('api.errors.record_not_found_error', klass: model)
    render_error(message, 404)
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end
