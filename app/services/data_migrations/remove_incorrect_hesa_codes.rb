module DataMigrations
  class RemoveIncorrectHesaCodes
    TIMESTAMP = 20210518233940
    MANUAL_RUN = false

    def change
      ApplicationForm.where.not(equality_and_diversity: nil).find_each do |application_form|
        remove_incorrect_codes_from(application_form)
      end
    end

  private

    def remove_incorrect_codes_from(application_form)
      if disabilities_not_specified?(application_form) && hesa_disabilities_present?(application_form)
        reset_disabilities(application_form)
      end

      if ethnicity_not_specified?(application_form) && hesa_ethnicity_present?(application_form)
        reset_ethnicity(application_form)
      end
    end

    def disabilities_not_specified?(application_form)
      disabilities = application_form.equality_and_diversity.dig('disabilities')
      disabilities.blank? || disabilities == %w[no] || disabilities == ['Prefer not to say']
    end

    def hesa_disabilities_present?(application_form)
      hesa_disabilities = application_form.equality_and_diversity.dig('hesa_disabilities')
      !hesa_disabilities.nil? && hesa_disabilities != []
    end

    def reset_disabilities(application_form)
      application_form.equality_and_diversity['hesa_disabilities'] = []
      application_form.audit_comment = 'Resetting incorrect HESA disability codes. See https://trello.com/c/U7W3r0tj/3402'
      application_form.save!
    end

    def ethnicity_not_specified?(application_form)
      ethnicity_group = application_form.equality_and_diversity.dig('ethnic_group')
      ethnicity_group.blank? || ethnicity_group == 'Prefer not to say'
    end

    def hesa_ethnicity_present?(application_form)
      application_form.equality_and_diversity.dig('hesa_ethnicity').present?
    end

    def reset_ethnicity(application_form)
      application_form.equality_and_diversity['hesa_ethnicity'] = nil
      application_form.audit_comment = 'Resetting incorrect HESA ethnicity code. See https://trello.com/c/U7W3r0tj/3402'
      application_form.save!
    end
  end
end
