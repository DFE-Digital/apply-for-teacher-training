class AddFindFeedbackTable < ActiveRecord::Migration[6.0]
  def change
    create_table :find_feedback do |t|
      t.string :path, null: false
      t.string :original_controller, null: false
      t.string :feedback, null: false
      t.string :email_address
      t.timestamps
    end
  end
end
