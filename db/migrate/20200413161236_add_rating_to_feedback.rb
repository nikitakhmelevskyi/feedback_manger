class AddRatingToFeedback < ActiveRecord::Migration[5.2]
  def change
    add_column :feedback, :rating, :integer, null: false
  end
end
