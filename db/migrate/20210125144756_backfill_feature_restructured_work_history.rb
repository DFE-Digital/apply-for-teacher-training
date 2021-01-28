class BackfillFeatureRestructuredWorkHistory < ActiveRecord::Migration[6.0]
  def change
    application_forms = ApplicationForm
                          .left_outer_joins(:application_work_experiences)
                          .where('application_experiences.id IS NOT NULL OR work_history_explanation is NOT NULL')
                          .distinct

    application_forms.find_each do |application_form|
      application_form.update!(feature_restructured_work_history: false)
    end
  end
end
