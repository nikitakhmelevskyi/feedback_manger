class AddQuestionReferenceToResponses < ActiveRecord::Migration[5.2]
  def change
    remove_column :responses, :question, :string, null: false
    add_reference :responses, :question, index: true, foreign_key: true
  end
end
