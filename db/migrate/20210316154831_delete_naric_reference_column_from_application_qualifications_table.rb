class DeleteNaricReferenceColumnFromApplicationQualificationsTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_qualifications, :naric_reference, :string
  end
end
