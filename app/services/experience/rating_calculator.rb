class Experience::RatingCalculator
  QUESTION_IDENTIFIER = 'Rate the experience'.freeze
  QUERY = <<-SQL.freeze
    SELECT round(AVG(prepared_ratings.rating), 1) AS avg_rating
    FROM (
      SELECT NULLIF(regexp_replace(answer, '[^1-5]','','g'), '')::INTEGER AS rating
      FROM feedback
      INNER JOIN responses ON responses.feedback_id = feedback.id
      WHERE feedback.experience_id = '%{experience_id}'
      AND responses.question = '%{question_identifier}'
      AND responses.answer IS NOT NULL
    ) prepared_ratings
  SQL

  def self.call(experience)
    return if experience.blank?

    result = ActiveRecord::Base.connection.execute(
      QUERY % { experience_id: experience.id, question_identifier: QUESTION_IDENTIFIER }
    )

    result.first['avg_rating'].to_f if result.any?
  end
end
