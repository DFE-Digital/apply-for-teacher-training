class AddPublicIdToQualifications < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :constituent_grades, :jsonb
    add_column :application_qualifications, :public_id, :bigint
  end
end
