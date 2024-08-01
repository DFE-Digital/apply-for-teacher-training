class ValidateAddDeleteCascadeToRejectionFeedbacks < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :rejection_feedbacks, :application_choices
  end
end
