class BackfillApplicationFormHesaSexAndEthnicityCode
  def self.call(application_form)
    equality_and_diversity = application_form.equality_and_diversity
    equality_and_diversity['hesa_sex'] = equality_and_diversity['hesa_sex'].presence&.to_s
    equality_and_diversity['hesa_ethnicity'] = equality_and_diversity['hesa_ethnicity'].presence&.to_s
    application_form.update_column(:equality_and_diversity, equality_and_diversity)
  end
end
