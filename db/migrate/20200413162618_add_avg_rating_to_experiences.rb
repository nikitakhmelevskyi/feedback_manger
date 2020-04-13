class AddAvgRatingToExperiences < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :avg_rating, :float
  end
end
