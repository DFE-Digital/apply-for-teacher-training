class AddEnicReferenceColumnToApplicationQualificationsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :enic_reference, :string
  end
end
