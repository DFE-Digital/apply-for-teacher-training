class AddAccreditingProviderToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :accrediting_provider_id, :integer
  end
end
