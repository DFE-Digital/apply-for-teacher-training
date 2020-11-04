class AddGradesToApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :grades, :jsonb
  end
end
