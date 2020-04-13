class CreateResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :responses do |t|
      t.references :feedback, index: true, foreign_key: { to_table: :feedback }
      t.string :question, null: false
      t.string :answer
      t.timestamps
    end
  end
end
