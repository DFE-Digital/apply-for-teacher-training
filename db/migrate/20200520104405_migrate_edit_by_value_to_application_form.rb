class MigrateEditByValueToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    application_forms = ApplicationForm.includes(:application_choices).where.not(submitted_at: nil)

    application_forms.each do |application_form|
      edit_by = application_form.application_choices.first&.edit_by
      application_form.update(edit_by: edit_by)
    end
  end
end
