class BackfillHesaSexAndEthnicityCodes < ActiveRecord::Migration[6.0]
  def change
    application_forms_with_equality_and_diversity_data = ApplicationForm.where.not(equality_and_diversity: nil)
    application_forms_with_equality_and_diversity_data.each do |application_form|
      BackfillApplicationFormHesaSexAndEthnicityCode.call(application_form)
    end
  end
end
