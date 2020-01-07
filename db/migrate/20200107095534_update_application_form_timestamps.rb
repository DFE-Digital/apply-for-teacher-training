class UpdateApplicationFormTimestamps < ActiveRecord::Migration[6.0]
  def up
    ApplicationForm.includes(:application_choices).find_each do |application_form|
      max_updated_at = [
        application_form.updated_at,
        application_form.application_choices.map(&:updated_at),
      ].flatten.max

      application_form.update_columns(updated_at: max_updated_at)
    end
  end

  def down; end
end
