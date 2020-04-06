class RemoveCoursesAccreditingProviderId < ActiveRecord::Migration[6.0]
  def change
    remove_column :courses, :accrediting_provider_id, :integer
  end
end
