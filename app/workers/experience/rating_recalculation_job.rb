class Experience::RatingRecalculationJob
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(experience_id)
    experience = Experience.find_by_id(experience_id)

    Experience::RatingUpdater.call(experience)
  end
end
