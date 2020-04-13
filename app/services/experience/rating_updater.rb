class Experience::RatingUpdater
  def self.call(experience)
    return if experience.blank?

    experience.update!(
      avg_rating: Experience::RatingCalculator.call(experience)
    )
  end
end
