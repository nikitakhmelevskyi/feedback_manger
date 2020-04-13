class CreateFeedback < ActiveRecord::Migration[5.2]
  def change
    create_table :feedback do |t|
      t.references :experience, index: true, foreign_key: true
      t.timestamps
    end
  end
end
