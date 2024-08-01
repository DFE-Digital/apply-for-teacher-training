class AddDeleteCascadeToRejectionFeedbacks < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :rejection_feedbacks, :application_choices
    add_foreign_key :rejection_feedbacks, :application_choices, on_delete: :cascade, validate: false
  end
end
