class RemoveAwardingBodyFromApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_qualifications, :awarding_body, :string
  end
end
