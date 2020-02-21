class AddEqualityAndDiversityToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :equality_and_diversity, :jsonb
  end
end
