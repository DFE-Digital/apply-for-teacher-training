class AddAccreditingProviderToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :accrediting_provider_id, :integer
    add_index :courses, %i[accrediting_provider_id code], unique: true
  end
end
