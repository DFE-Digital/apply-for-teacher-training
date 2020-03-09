class AddSafeguardingIssuesToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :safeguarding_issues, :text
  end
end
