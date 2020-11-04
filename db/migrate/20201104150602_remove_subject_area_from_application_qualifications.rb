class RemoveSubjectAreaFromApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_qualifications, :subject_area, type: :string
  end
end
