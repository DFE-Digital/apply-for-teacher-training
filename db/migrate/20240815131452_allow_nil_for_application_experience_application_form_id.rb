class AllowNilForApplicationExperienceApplicationFormId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :application_experiences, :application_form_id, true
  end
end
