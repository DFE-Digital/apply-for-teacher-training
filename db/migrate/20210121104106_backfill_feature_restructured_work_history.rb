class BackfillFeatureRestructuredWorkHistory < ActiveRecord::Migration[6.0]
  def change
    application_forms = ApplicationForm
                        .includes(:application_work_experiences)
                        .select do |application_form|
                          application_form.application_work_experiences.any? ||
                            application_form.work_history_explanation.present?
                        end

    application_forms.each do |application_form|
      application_form.update!(feature_restructured_work_history: false)
    end
  end
end
