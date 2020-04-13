class Experience::RatingCalculator
  def self.call(experience)
    return if experience.blank?

    avg_rating = experience.feedback.average(:rating)

    avg_rating.to_f.round(1) if avg_rating.present?
  end
end
