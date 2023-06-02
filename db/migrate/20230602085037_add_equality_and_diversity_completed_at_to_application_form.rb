class AddEqualityAndDiversityCompletedAtToApplicationForm < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :equality_and_diversity_completed_at, :timestamp, precision: nil
  end
end
