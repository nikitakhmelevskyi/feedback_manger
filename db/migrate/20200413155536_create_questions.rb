class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :experience, index: true, foreign_key: true
      t.string :text, null: false
      t.timestamps
    end
  end
end
