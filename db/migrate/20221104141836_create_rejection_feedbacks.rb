class CreateRejectionFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :rejection_feedbacks do |t|
      t.boolean :helpful, null: false, default: false
      t.references :application_choice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
