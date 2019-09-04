class AddAccreditedBodyProviderIdToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :accredited_body_provider_id, :integer
  end
end
