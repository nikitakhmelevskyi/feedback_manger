class CreateExperiences < ActiveRecord::Migration[5.2]
  def change
    create_table :experiences do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
