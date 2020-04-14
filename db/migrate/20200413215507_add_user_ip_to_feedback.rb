class AddUserIpToFeedback < ActiveRecord::Migration[5.2]
  def change
    add_column :feedback, :user_ip, :string
    add_index :feedback, [:experience_id, :user_ip], unique: true
  end
end
